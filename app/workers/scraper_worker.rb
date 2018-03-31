class ScraperWorker
  include Sidekiq::Worker
  include Scrapers
  include Loaders


  def perform(options)
    if options[:search_location]
      @scraper = Scrapers::ScraperDispatch.new(options[:website])
      if options[:load_point_of_interest]
        loader = Loaders::LoaderPointsOfInterest.new()
        loader.points_of_interest(options[:search_location]).each do |l|
          scrap_logic(options.merge(search_query: l[:query], point_of_interest: l[:point_of_interest]))
        end
      end
      scrap_logic(options)
    end
  end

  private

  def scrap_logic(options)
    # Get listings URLs and Prices
    all_urls_and_prices = @scraper.get_listings_urls_and_prices(options)
    p "------- #{all_urls_and_prices.length} URLS ---------"
    # Check what listings are new, have been updated or closed
    listings = Property.filter_listings(all_urls_and_prices, options)
    p "NEW : #{listings[:new].length} "
    p "UPDATED : #{listings[:updated].length} "
    p "CLOSED : #{listings[:closed].length} "
    # Close listings that have been closed
    close_listings(listings[:closed])
    # Update listings that have been updated
    update_listings(listings[:updated])
    # Scrap new listings
    create_listings(listings[:new], options)
  end

  def close_listings(listings, options = {})
    p '------- CLOSING LISTINGS --------'
    listings.each_with_index do |l,i|
      p "CLOSING : #{i+1} / #{listings[:closed].length}"
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

  def update_listings(listings, options = {})
    p '------- UPDATING LISTINGS --------'
    listings.each_with_index do |l,i|
      p "UPDATING : #{i+1} / #{listings[:updated].length}"
      begin
        prop = Property.find(l[:id])
        prop.update_listing({price: l[:price]})
      rescue
        p 'Error - listing could not be updated'
      end
    end
  end

  def create_listings(listings, options = {})
    p '------- CREATING LISTINGS --------'
    listings.each_with_index do |l,i|
      p "CREATING : #{i+1} / #{listings[:new].length}"
        prop = @scraper.scrap_one_listing(l[:url])
        Property.save_new_listing(prop.merge(urls: l[:url],
          status: 'open',
          search_location: options[:search_location],
          location: (options[:point_of_interest] || prop[:location])))
    end
  end
end

