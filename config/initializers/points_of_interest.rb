require 'csv'

POINTS_OF_INTEREST = []
filepath = 'app/data/points_of_interest.csv'
csv_options = { col_sep: ',', force_quotes: true, quote_char: '"' }
CSV.foreach(filepath, csv_options) do |row|
  unless row[0].nil?
    point = {
      type: row[0].downcase,
      location: row[1].downcase,
      point_of_interest: "#{row[3].downcase if row[3]}, #{row[2].downcase if row[2]}, #{row[1].downcase if row[1]}"
    }
    row[3] ? point[:query] = row[3].downcase : point[:query] = row[2].downcase
    POINTS_OF_INTEREST << point
  end
end
