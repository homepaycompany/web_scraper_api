class ScraperWorker
  include Sidekiq::Worker
  include Scrapers


  def perform(website)
    options = {location: 'toulouse', property_type: [:house, :appartment], min_price: 100000, max_price: 400000, user_type: :owner}
    if options[:location]
      # Instantiate scraper
      scraper = Scrapers::ScraperDispatch.new(website)
      # Get listings URLs and Prices
      all_urls_and_prices = scraper.get_listings_urls_and_prices(options)
      p "------- #{all_urls_and_prices.length} URLS ---------"
      # Check what listings are new, have been updated or closed
      listings_full = Property.filter_listings(all_urls_and_prices, options)
      p "NEW : #{listings_full[:new].length} "
      p "UPDATED : #{listings_full[:updated].length} "
      p "CLOSED : #{listings_full[:closed].length} "
      # Break up list of url to scrap in smaller pieces for later jobs if necessary
      # =========== TBD
      listings_small = listings_full
      i = 1
      # Close listings that have been closed
      p '------- CLOSING LISTINGS --------'
      listings_small[:closed].each do |l|
        p "CLOSING : #{i} / #{listings_full[:closed].length}"
        begin
            p = Property.find(l[:id])
            a = true
            p.urls_array.each do |u|
              a = a & scrapper.add_is_removed?(u)
            end
            if a
              all_updates = p.all_updates + ",c-#{p.removed_on}"
              p.update({
                status: 'closed',
                removed_on: Time.now.strftime("%d/%m/%Y"),
                all_updates: all_updates
                })
            end
          rescue
          p 'Error - listing could not be closed'
        end
        i += 1
      end
      i = 1
      # Update listings that have been updated
      p '------- UPDATING LISTINGS --------'
      listings_small[:updated].each do |l|
        p "UPDATING : #{i} / #{listings_full[:updated].length}"
        begin
          p = Property.find(l[:id])
          all_updates = p.all_updates + ",u-#{Time.now.strftime("%d/%m/%Y")}"
          all_prices = p.all_prices + ",#{l[:price]}"
          p.update({
            status: 'updated',
            updated_on: Time.now.strftime("%d/%m/%Y"),
            price: l[:price],
            all_updates: all_updates,
            all_prices: all_prices
            })
        rescue
          p 'Error - listing could not be updated'
        end
        i += 1
      end
      i = 1
      # Scrap new listings
      p '------- CREATING LISTINGS --------'
      listings_small[:new].each do |l|
        p "CREATING : #{i} / #{listings_full[:new].length}"
        begin
          p = scraper.scrap_one_listing(l[:url])
          Property.save_new_listing(p.merge(urls: l[:url], status: 'open'))
        rescue
          p 'Error - listing could not be created'
        end
        i += 1
      end
    end

    # TEST SECTION
    # p = Property.last.attributes
    # p p['id']
    # p['description'] = "A vendre mai environ 130 m² le chat est beau à la campagne sur un terrain une cuisine aménagée et équipée, 3 grandes chambres dont une de 20 partir d'ici le matin camion campagne ains wcA l'étage une grande pièce de 25 m² (55 au sol) + grenier aménageableChauffage central bois + fuel"
    # Property.save_new_listing(p.merge(urls: 'test', status: 'open'))
  end

end

