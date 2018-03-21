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
      # Break up list of url to scrap in smaller pieces for later jobs if necessary
      # =========== TBD
      listings_small = listings_full
      # Close listings that have been closed
      listings_small[:closed].each do |l|
        begin
          p = Property.find(l[:id])
          p.status = 'closed'
          p.removed_on = Time.now.strftime("%d/%m/%Y")
          p.all_updates += ",#{p.removed_on}"
          p.save
        rescue
          p 'Error - listing could not be closed'
        end
      end
      # Update listings that have been updated
      listings_small[:updated].each do |l|
        begin
          p = Property.find(l[:id])
          p.status = 'updated'
          p.updated_on = Time.now.strftime("%d/%m/%Y")
          p.all_updates += ",#{Time.now.strftime("%d/%m/%Y")}"
          p.all_prices += ",#{l[:price]}"
          p.price = l[:price]
          p.save
        rescue
          p 'Error - listing could not be updated'
        end
      end
      # Scrap new listings
      listings_small[:new].each do |l|
        begin
          p = scraper.scrap_one_listing(l[:url])
          Property.save_new_listing(p.merge(urls: l[:url], status: 'open'))
        rescue
          p 'Error - listing could not be created'
        end
      end
    end

    # TEST SECTION
    # p = Property.last.attributes
    # p p['id']
    # p['description'] = "A vendre mai environ 130 m² le chat est beau à la campagne sur un terrain une cuisine aménagée et équipée, 3 grandes chambres dont une de 20 partir d'ici le matin camion campagne ains wcA l'étage une grande pièce de 25 m² (55 au sol) + grenier aménageableChauffage central bois + fuel"
    # Property.save_new_listing(p.merge(urls: 'test', status: 'open'))
  end

end

