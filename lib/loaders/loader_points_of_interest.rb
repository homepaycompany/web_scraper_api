class Loaders::LoaderPointsOfInterest

  def initialize
  end

  def points_of_interest_full(search_location)
    POINTS_OF_INTEREST.select { |l| l[:location] == search_location.downcase }
  end

  def points_of_interest_queries_by_type(search_location)
    queries = { street: {}, area: {} }
    points_of_interest_full(search_location).each do |point|
      a = {}
      a[:full_name] = point[:point_of_interest]
      if point[:latitude] && point[:longitude]
        a[:latitude] = point[:latitude]
        a[:longitude] = point[:longitude]
      end
      queries[point[:type].to_sym][point[:query]] = a
    end
    return queries
  end
end
