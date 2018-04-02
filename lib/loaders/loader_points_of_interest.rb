class Loaders::LoaderPointsOfInterest

  def initialize
  end

  def points_of_interest(search_location)
    POINTS_OF_INTEREST.select { |l| l[:location] == search_location.downcase }
  end
end
