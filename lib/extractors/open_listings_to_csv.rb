# p 'Creating CSV File'

# csv_options = { col_sep: ',', force_quotes: true, quote_char: '"' }
# filepath    = 'urls.csv'
# CSV.open(filepath, 'wb', csv_options) do |csv|
#   csv << ['url']
# end

# p 'Retrieving properties from DB'
# Property.where(status: 'open', price: 150000..500000).each_with_index do |l,i|
#   p "property #{i}"
#   l.urls_array.each do |u|
#     CSV.open(filepath, 'a', csv_options) do |csv|
#       csv << [u]
#     end
#   end
# end

