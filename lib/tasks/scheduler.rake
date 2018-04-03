desc "This task is called by the Heroku scheduler add-on - scrapping listings in TOULOUSE"
task :scrap_listings_toulouse => :environment do
  options = {website: 'lbc',
    load_points_of_interest: false,
    search_params: {
      search_location: 'toulouse',
      property_type: ['house', 'appartment'],
      min_price: 100000,
      max_price: 100000
    }
  }
  ScraperWorker.perform_async(options)
end

desc "This task is called by the Heroku scheduler add-on - scrapping listings in PARIS"
task :scrap_listings_paris => :environment do
  options = {website: 'lbc',
    load_points_of_interest: true,
    search_params: {
      search_location: 'paris',
      property_type: ['house', 'appartment'],
      min_price: 100000,
      max_price: 1000000,
      user_type: 'all'}
    }
  ScraperWorker.perform_async(options)
end

desc "This task is called by the Heroku scheduler add-on - scrapping without job"
task :scrap_no_job => :environment do
  include Scrapers
  options = {website: 'lbc',
    load_points_of_interest: false,
    search_params: {
      search_location: 'toulouse',
      property_type: ['house', 'appartment'],
      min_price: 100000,
      max_price: 100000
    }
  }
  Scrapers::ScraperLogic.new().scrap(options)
end
