require 'csv'

POINTS_OF_INTEREST = []
filepath = 'app/data/points_of_interest.csv'
csv_options = { col_sep: ',', force_quotes: true, quote_char: '"' }
CSV.foreach(filepath, csv_options) do |row|
  unless row[0].nil?
    row[3] ? street = "#{row[3].downcase}, " : street = ''
    row[2] ? neighborhood = "#{row[2].downcase}, " : neighborhood = ''
    row[1] ? city = "#{row[1].downcase}" : city = ''
    point = {
      type: row[0].downcase,
      location: row[1].downcase,
      point_of_interest: "#{street}#{neighborhood}#{city}"
    }
    row[3] ? point[:query] = row[3].downcase : point[:query] = row[2].downcase
    POINTS_OF_INTEREST << point
  end
end
