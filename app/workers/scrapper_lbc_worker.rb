class ScraperLbcWorker
  include Sidekiq::Worker
  include Scrapers::ScraperDispatch

  # Get website to scrap
  website = 'lbc'
  # Get location to scrap
  location = 'toulouse'
  # Instantiate scraper
  scraper = Scrapers::ScraperDispatch.new(website)
  # Get listings URLs and Prices
  all_urls_and_prices = scraper.get_listings_urls_and_prices(location)
  # Check what listings are new, have been updated or closed
  # =========== TBD
  listings_check = {new: [{url: url}], updated: [{id: id, price: price}], closed: [{id: id}]}
  # Break up list of url to scrap in smaller pieces for later jobs if necessary
  # =========== TBD
  # Close listings that have been closed
  listings_check[:closed].each do |l|
    Property.find(l[:id]).update({
      status: 'closed',
      removed_on: Time.now.strftime("%d/%m/%Y")
      })
  end
  # Update listings that have been updated
  listings_check[:updated].each do |l|
    p = Property.find(l[:id])
    p.status = 'updated'
    p.updated_on = Time.now.strftime("%d/%m/%Y")
    p.all_updates += ",#{Time.now.strftime("%d/%m/%Y")}"
    p.all_prices += ",#{l[:price]}"
    p.price = l[:price]
    p.save
  end
  # Scrap new listings
  listings_check[:new].each do |l|
    p = scraper.scrap_one_listing(l[:url])
    p.save_new_listing
  end

end

