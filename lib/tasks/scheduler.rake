desc "This task is called by the Heroku scheduler add-on - scrapping listings in toulouse"
task :scrap_listings_toulouse => :environment do
  options = {website: 'lbc',
    search_params: {
      search_location: 'toulouse',
      property_type: ['house', 'appartment'],
      min_price: 100000,
      max_price: 1000000
    }
  }
  ScrapWorker.perform_async(options)
end

desc "This task is called by the Heroku scheduler add-on - scrapping listings in Paris"
task :scrap_listings_paris => :environment do
  options = {website: 'lbc',
    search_params: {
      search_location: 'paris',
      property_type: ['house', 'appartment'],
      min_price: 100000,
      max_price: 1000000
    }
  }
  ScrapWorker.perform_async(options)
end

desc "This task is called by the Heroku scheduler add-on - enriching listings locations with points of interest"
task :enrich_listings_location => :environment do
  EnrichListingsLocationWorker.perform_async
end

desc "This task is called by the Heroku scheduler add-on - enriching listings attributes by matching description"
task :enrich_listings_attributes => :environment do
  EnrichListingsAttributesWorker.perform_async
end
