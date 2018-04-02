desc "This task is called by the Heroku scheduler add-on - scrapping listings in Toulouse"
task :scrap_listings_toulouse => :environment do
  options = {website: 'lbc',
    load_points_of_interest: true,
    search_params: {
      search_location: 'paris',
      property_type: ['house', 'appartment'],
      min_price: 100000,
      max_price: 125000,
      user_type: 'owner'}
    }
  ScraperWorker.perform_async(options)
end

