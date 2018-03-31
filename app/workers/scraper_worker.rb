class ScraperWorker
  include Sidekiq::Worker
  include Scrapers


  def perform(website)
    options = {search_location: 'toulouse', property_type: [:house, :appartment], min_price: 100000, max_price: 1000000, user_type: :all}
    if options[:search_location]
      # Instantiate scraper
      scraper = Scrapers::ScraperDispatch.new(website)
      # Get listings URLs and Prices
      all_urls_and_prices = scraper.get_listings_urls_and_prices(options)
      p "------- #{all_urls_and_prices.length} URLS ---------"
      # Check what listings are new, have been updated or closed
      listings = Property.filter_listings(all_urls_and_prices, options)
      p "NEW : #{listings[:new].length} "
      p "UPDATED : #{listings[:updated].length} "
      p "CLOSED : #{listings[:closed].length} "
      # Close listings that have been closed
      p '------- CLOSING LISTINGS --------'
      listings[:closed].each_with_index do |l,i|
        p "CLOSING : #{i+1} / #{listings[:closed].length}"
        begin
            prop = Property.find(l[:id])
            a = true
            prop.urls_array.each do |u|
              a = a & scraper.is_add_removed?(u)
            end
            if a
              prop.close_listing
            else
              p 'Add has not be removed'
            end
          rescue
          p 'Error - listing could not be closed'
        end
      end
      # Update listings that have been updated
      p '------- UPDATING LISTINGS --------'
      listings[:updated].each_with_index do |l,i|
        p "UPDATING : #{i+1} / #{listings[:updated].length}"
        begin
          prop = Property.find(l[:id])
          prop.update_listing({price: l[:price]})
          # all_updates = prop.all_updates + ",u-#{Time.now.strftime("%d/%m/%Y")}"
          # all_prices = prop.all_prices + ",#{l[:price]}"
          # prop.update({
          #   status: 'updated',
          #   updated_on: Time.now.strftime("%d/%m/%Y"),
          #   price: l[:price],
          #   all_updates: all_updates,
          #   all_prices: all_prices
          #   })
        rescue
          p 'Error - listing could not be updated'
        end
      end
      # Scrap new listings
      p '------- CREATING LISTINGS --------'
      listings[:new].each_with_index do |l,i|
        p "CREATING : #{i+1} / #{listings[:new].length}"
          prop = scraper.scrap_one_listing(l[:url])
          Property.save_new_listing(prop.merge(urls: l[:url], status: 'open', search_location: options[:search_location]))
      end
    end
  end

end

