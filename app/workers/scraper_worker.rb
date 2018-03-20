class ScraperWorker
  include Sidekiq::Worker
  include Scrapers


  def perform(website)
    options = {location: 'toulouse', property_type: [:house], min_price: 100000, max_price: 150000}
    if options[:location]
      # Instantiate scraper
      scraper = Scrapers::ScraperDispatch.new(website)
      # Get listings URLs and Prices
      all_urls_and_prices = scraper.get_listings_urls_and_prices(options)
      # Check what listings are new, have been updated or closed
      # =========== TBD
      listings_full = Property.filter_listings(all_urls_and_prices)
      p listings_full
      # Break up list of url to scrap in smaller pieces for later jobs if necessary
      # =========== TBD
      listings_small = listings_full
      # Close listings that have been closed
      listings_small[:closed].each do |l|
        Property.find(l[:id]).update({
          status: 'closed',
          removed_on: Time.now.strftime("%d/%m/%Y")
          })
      end
      # Update listings that have been updated
      listings_small[:updated].each do |l|
        p = Property.find(l[:id])
        p.status = 'updated'
        p.updated_on = Time.now.strftime("%d/%m/%Y")
        p.all_updates += ",#{Time.now.strftime("%d/%m/%Y")}"
        p.all_prices += ",#{l[:price]}"
        p.price = l[:price]
        p.save
      end
      # Scrap new listings
      listings_small[:new].each do |l|
        p 'hello from scrap_new_listings ---------------------'
        p = scraper.scrap_one_listing(l[:url])
        Property.create(p)
        # p.save_new_listing
      end
    end
  end

end

