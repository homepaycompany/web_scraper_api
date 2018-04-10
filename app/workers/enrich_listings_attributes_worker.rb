class EnrichListingsAttributesWorker
  include Sidekiq::Worker
  include RegexMatchers

  def perform
    regex_matcher = RegexMatchers::MatcherListingAttributes.new()
    properties = Property.where(need_to_enrich_attributes: true)
    properties.each do |property|
      begin
        p l.id
        regex_matcher.enrich_listing_attributes(property)
        property.attributes_enriched_at = Time.now
        property.save
      rescue
        p 'Error - could not enrich listing attributes'
      end
    end
  end
end
