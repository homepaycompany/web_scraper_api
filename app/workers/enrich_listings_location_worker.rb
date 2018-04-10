# Job that iterates through listings with inexact locations and tries to add a point of
# interest by matching the listing's name + description to the points of interest list
class EnrichListingsLocationWorker
  include Sidekiq::Worker
  include Loaders
  include RegexMatchers

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
    p "-------------------------------------- #{property.id}"
    r = {street: {}, area: {}}
    begin
      points_of_interest.each do |type, points|
        points.keys.each do |point|
          point_sanithized = @regex_matcher.get_sanithized_string(point)
          z = s.index (/#{point_sanithized}/i)
          if z
            r[type][point] = z
          else
            trigrams = point_sanithized.trigrams.map { |t| t.join }
            trigrams[0..(trigrams.length / 2) + 1].each_with_index do |t, i|
              t_matches = []
              u = -1
              while u && u + 2 < s.length - 1
                q = u
                u = s[u + 1..s.length - 1].index(/#{t}/i)
                if u
                  u += q + 1
                  t_matches << u
                end
              end
              g = 0
              while !t_matches.empty? && g < trigrams.length * 0.8
                trigrams[i + 1..trigrams.length - 1].each_with_index do |trig, j|
                  t_min = [t_matches.first + 1 + j, s.length - 1].min
                  t_max = [t_matches.first + 5 + j, s.length - 1].min
                   m = s[t_min..t_max].index(/#{trig}/i)
                   if m
                    g += 1
                   end
                end
                if g >= trigrams.length * 0.8
                  r[type][point] ||= t_matches.first
                else
                  t_matches.shift
                  g = 0
                end
              end
            end
          end
        end
      end
    rescue
      p "Error - Couldn't match property"
    end
    begin
      if !r[:street].empty?
        m = r[:street].min_by { |k,v| v }.first
        address = points_of_interest[:street][m]
      elsif !r[:area].empty?
        m = r[:area].min_by { |k,v| v }.first
        address = points_of_interest[:area][m]
      end
      if m
        property.address = address
        property.geocode
        property.location_type = 'point_of_interest'
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
end
