class EnrichListingsAttributesWorker
  include Sidekiq::Worker
  include RegexMatchers

  def perform
    regex_matcher = RegexMatchers::RegexMatcher.new()
    listings = Property.where(need_to_enrich_attributes: true)
    listings[0..5].each do |l|
      p l.id
        regex_matcher.enrich_listing_attributes(l)
        l.save
      # begin
      # rescue
      #   p 'Error - could not enrich listing attributes'
      # end
    end
  end
end
