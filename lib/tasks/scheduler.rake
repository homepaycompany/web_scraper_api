desc "This task is called by the Heroku scheduler add-on - scrapping listings"
task :scrap_listings => :environment do
  cities = ['toulouse', 'paris']
  options = {website: 'lbc',
    search_params: {
      property_type: ['house', 'appartment'],
      min_price: 100000,
      max_price: 100000
    }
  }
  cities.each do |c|
    options[:search_params][:search_location] = c
    ScrapWorker.perform_async(options)
  end
end

desc "This task is called by the Heroku scheduler add-on - enriching listings locations with points of interest"
task :add_point_of_interest_to_listings => :environment do
  AddPointOfInterestWorker.perform_async
end


# desc "This task is called by the Heroku scheduler add-on - scrapping without job"
# task :scrap_no_job => :environment do
#   include Scrapers
#   options = {website: 'lbc',
#     load_points_of_interest: false,
#     search_params: {
#       search_location: 'toulouse',
#       property_type: ['house', 'appartment'],
#       min_price: 100000,
#       max_price: 100000
#     }
#   }
#   Scrapers::ScraperLogic.new().scrap(options)
# end
