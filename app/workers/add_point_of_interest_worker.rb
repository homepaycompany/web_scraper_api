# Job that iterates through listings with inexact locations and tries to add a point of
# interest by matching the listing's name + description to the points of interest list
class AddPointOfInterestWorker
  include Sidekiq::Worker
  include Loaders

  def perform
    @loader = Loaders::LoaderPointsOfInterest.new()
    properties = Property.where(need_to_enrich_location: true)
    properties.each do |property|
      add_point_of_interest(property)
    end
  end

  def add_point_of_interest(property)
    points = @loader.points_of_interest(property.search_location)
    i = 0
    # while property.need_to_enrich_location && i < points.length
      r = FuzzyMatch.new(points).find("#{property.name} #{property.description}")
      m = Amatch::PairDistance.new(r)
      q = m.match("#{property.name} #{property.description}")
      if q > 0.95
        property.address = r
        property.geocode
        property.location_type = 'point_of_interest'
        # property.need_to_enrich_location = false
      end
    #   i += 1
    # end
    property.need_to_enrich_location = false
    begin
      property.save
    rescue
      p 'Error - property location could not be enriched'
    end
  end
end
