require 'csv'

POINTS_OF_INTEREST = []
filepath = 'app/data/points_of_interest.csv'
csv_options = { col_sep: ',' }
CSV.foreach(filepath, csv_options) do |row|
  unless row[0].nil?
    !row[3].nil? ? street = "#{row[3].downcase}, " : street = ''
    !row[2].nil? ? neighborhood = "#{row[2].downcase}, " : neighborhood = ''
    !row[1].nil? ? city = "#{row[1].downcase}" : city = ''
    point = {
      type: row[0].downcase,
      location: row[1].downcase,
      point_of_interest: "#{street}#{neighborhood}#{city}"
    }
    !row[3].nil? ? point[:query] = row[3].downcase : point[:query] = row[2].downcase
    if !row[4].nil? && !row[5].nil?
      point[:latitute] = row[4].to_f
      point[:longitude] = row[5].to_f
    end
    POINTS_OF_INTEREST << point
  end
end
