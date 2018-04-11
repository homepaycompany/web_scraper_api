class Api::V1::PropertiesController < Api::V1::BaseController
  def download_to_csv
    options = params || {}
    properties = Property.where(search_location: 'paris')
    authorize properties.first
    send_data(Property.to_csv(properties), :filename => "properties.csv")
  end
end
