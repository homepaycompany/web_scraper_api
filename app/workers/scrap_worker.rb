class ScrapWorker
  include Sidekiq::Worker

  def perform(options)
    options = options.symbolize_keys
    search_params = options[:search_params].symbolize_keys
    if search_params[:search_location]
      @scraper = Scrapers::ScraperDispatch.new(options[:website])
      scrap_logic(search_params)
    end
  end

  private

  def scrap_logic(search_params)
    # Get listings URLs and Prices
    all_urls_and_prices = @scraper.get_listings_urls_and_prices(search_params)
    p "------- #{all_urls_and_prices.length} URLS ---------"
    # # Check what listings are new, have been updated or closed
    # listings = Property.filter_listings(all_urls_and_prices, search_params)
    # p "NEW : #{listings[:new].length} "
    # p "UPDATED : #{listings[:updated].length} "
    # p "CLOSED : #{listings[:closed].length} "
    # # Close listings that have been closed
    # close_listings(listings[:closed])
    # # Update listings that have been updated
    # update_listings(listings[:updated])
    # # Scrap new listings
    # create_listings(listings[:new], search_params)
  end

  def close_listings(listings)
    p '------- CLOSING LISTINGS --------'
    listings.each_with_index do |l,i|
      p "CLOSING : #{i + 1} / #{listings.length}"
      begin
          prop = Property.find(l[:id])
          a = true
          prop.urls_array.each do |u|
            a = a & @scraper.is_add_removed?(u)
          end
          if a
            prop.close_listing
          else
            p 'Listing has not been removed'
          end
        rescue
        p 'Error - listing could not be closed'
      end
    end
  end

  def update_listings(listings)
    p '------- UPDATING LISTINGS --------'
    listings.each_with_index do |l,i|
      p "UPDATING : #{i + 1} / #{listings.length}"
      begin
        prop = Property.find(l[:id])
        prop.update_listing({price: l[:price]})
      rescue
        p 'Error - listing could not be updated'
      end
    end
  end

  def create_listings(listings, search_params = {})
    p '------- CREATING LISTINGS --------'
    listings.each_with_index do |l,i|
      p "CREATING : #{i + 1} / #{listings.length}"
      prop = @scraper.scrap_one_listing(l[:url])
      params = prop.merge(urls: l[:url],
        status: 'open',
        search_location: search_params[:search_location])
      begin
        Property.save_new_listing(params)
      rescue
        p 'Error - listing could not be created'
      end
    end
  end
end

