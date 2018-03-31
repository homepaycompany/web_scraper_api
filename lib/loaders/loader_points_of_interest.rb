class Loaders::LoaderPointsOfInterest
  require 'uri'
  require 'csv'

  def initialize
    @filepath = 'points_of_interest.csv'
    @points_of_interest_all = []
    load_points_of_interest
  end

  def points_of_interest(search_location)
    @points_of_interest_all.select { |l| l[:location] == search_location.downcase }
  end

  private

  def load_points_of_interest
    @points_of_interest_all = []
    CSV.foreach(@filepath) do |row|
      @points_of_interest_all << {location: row[0].downcase,
        query: row[2].downcase.force_encoding('ASCII-8BIT'),
        point_of_interest: "#{row[2].downcase}, #{row[1].downcase}, #{row[0].downcase}"}
    end
  end
end
