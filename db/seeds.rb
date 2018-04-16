# require 'csv'

# filepath = 'app/data/points_of_interest_2.csv'
# csv_options = { col_sep: ',' }
# rows = []
# i = 1
# CSV.foreach(filepath, csv_options) do |row|
#   p "#{i}"
#   if row[4].nil? && row[5].nil?
#     !row[3].nil? ? street = "#{row[3].downcase}, " : street = ''
#     !row[2].nil? ? neighborhood = "#{row[2].downcase}, " : neighborhood = ''
#     !row[1].nil? ? city = "#{row[1].downcase}" : city = ''
#     point_of_interest = "#{street}#{neighborhood}#{city}"
#     c = Geocoder.coordinates(point_of_interest)
#     unless c.nil?
#       row[4] = c[0]
#       row[5] = c[1]
#     end
#   end
#   rows << row
#   i += 1
# end

# filepath = 'app/data/points_of_interest_3.csv'
# rows.each do |row|
#   CSV.open(filepath, 'a+', csv_options) do |csv|
#     csv << row
#   end
# end


