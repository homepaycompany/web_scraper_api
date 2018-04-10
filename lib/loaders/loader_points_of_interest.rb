class Loaders::LoaderPointsOfInterest

  def initialize
  end

  def points_of_interest_full(search_location)
    POINTS_OF_INTEREST.select { |l| l[:location] == search_location.downcase }
  end

  def points_of_interest_queries(search_location)
    queries = { street: [], area: [] }
    points_of_interest_full(search_location).each do |point|
      queries[point[:type].to_sym] << point[:query]
    end
    return queries
  end
end
