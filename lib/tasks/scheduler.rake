desc "This task is called by the Heroku scheduler add-on - scrapping listings in toulouse"
task :scrap_listings => :environment do
  options = {
    website: 'lbc',
    cities: ['toulouse', 'paris', 'boulogne-billancourt'],
    search_params: {
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

desc "This task is called by the Heroku scheduler add-on - check if there are alerts and send them to the users"
task :send_all_alerts_emails => :environment do
  SendAllAlertsWorker.perform_async
end

desc "This task is called by the Heroku scheduler add-on - remove duplicate properties"
task :remove_duplicate_properties => :environment do
  RemoveDuplicatePropertiesWorker.perform_async
end
