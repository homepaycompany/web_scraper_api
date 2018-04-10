desc "This task is called by the Heroku scheduler add-on - scrapping listings"
task :scrap_listings => :environment do
  cities = ['toulouse', 'paris']
  options = {website: 'lbc',
    search_params: {
      property_type: ['house', 'appartment'],
      min_price: 100000,
      max_price: 1000000
    }
  }
  cities.each do |c|
    options[:search_params][:search_location] = c
    ScrapWorker.perform_async(options)
  end
end

desc "This task is called by the Heroku scheduler add-on - enriching listings locations with points of interest"
task :enrich_listings_location => :environment do
  EnrichListingsLocationWorker.perform_async
end

desc "This task is called by the Heroku scheduler add-on - enriching listings attributes by matching description"
task :enrich_listings_attributes => :environment do
  EnrichListingsAttributesWorker.perform_async
end
