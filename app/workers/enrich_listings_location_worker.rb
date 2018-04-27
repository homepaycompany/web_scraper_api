# Job that iterates through listings with inexact locations and tries to add a point of
# interest by matching the listing's name + description to the points of interest list
class EnrichListingsLocationWorker
  include Sidekiq::Worker

  def perform
    @loader = Loaders::LoaderPointsOfInterest.new()
    @regex_matcher = RegexMatchers::MatcherListingLocation.new()
    properties = Property.where(need_to_enrich_location: true).where(search_location: 'paris')
    properties.each do |property|
      add_point_of_interest(property)
    end
  end

  def add_point_of_interest(property)
    points_of_interest = @loader.points_of_interest_queries_by_type(property.search_location)
    s = @regex_matcher.get_sanithized_string("#{property.name} #{property.description}")
    p "----- #{property.id}"
    r = {street: {}, area: {}}
    begin
      points_of_interest.each do |type, points|
        points.keys.each do |point|
          point_sanithized = @regex_matcher.get_sanithized_string(point)
          z = s.index (/#{point_sanithized}/i)
          if z
            r[type][point] = z
          end
        end
      end
    rescue
      p "Error - Couldn't match property"
    end
    begin
      city_coords = Geocoder.coordinates(property.city)
      point_of_interest_coords = []
      address = ''
      i = false
      j = false
      while !r[:street].empty? && !i
        p 'iterating street'
        m = r[:street].min_by { |k,v| v }.first
        point_hash = validate_point_of_interest!(points_of_interest, point_of_interest_coords, city_coords, m, address, 'street')
        if point_hash
          address = point_hash.keys.first
          point_of_interest_coords = point_hash.values.first
          i = true
        else
          r[:street].delete(m)
          m = nil
        end
      end
      while !r[:area].empty? && !i && !j
        p 'iterating area'
        m = r[:area].min_by { |k,v| v }.first
        point_hash = validate_point_of_interest!(points_of_interest, point_of_interest_coords, city_coords, m, address, 'area')
        if point_hash
          address = point_hash.keys.first
          point_of_interest_coords = point_hash.values.first
          j = true
        else
          r[:area].delete(m)
          m = nil
        end
      end
      if m
        p address
        property.address = address
        property.location_type = 'point_of_interest'
        property.latitude = point_of_interest_coords[0]
        property.longitude = point_of_interest_coords[1]
      else
        property.latitude = city_coords[0]
        property.longitude = city_coords[1]
      end
      property.need_to_enrich_location = false
      property.location_enriched_at = Time.now
    rescue
      p "Error - couldn't geocode property"
    end
    begin
      property.save
    rescue
      p 'Error - property location could not be enriched'
    end
  end

  def validate_point_of_interest!(points_of_interest, point_of_interest_coords, city_coords, m, address, type)
    point = points_of_interest[type.to_sym][m]
    address = point[:full_name]
    if point[:latitude]
      point_of_interest_coords = [point[:latitude], point[:longitude]]
    else
      point_of_interest_coords = Geocoder.coordinates(address)
    end
    if Geocoder::Calculations.distance_between(city_coords, point_of_interest_coords) < 800
      {address => point_of_interest_coords}
    else
      return false
    end
  end
end
