desc "This task is called by the Heroku scheduler add-on - scrapping listings in Toulouse"
task :scrap_listings_toulouse => :environment do
  options = {website: 'lbc',
    location: 'toulouse',
    property_type: [:house, :appartment],
    min_price: 100000,
    max_price: 700000,
    user_type: :all,
    load_point_of_interest: true}
  ScraperWorker.perform_async(options)
end

