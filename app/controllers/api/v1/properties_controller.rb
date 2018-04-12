class Api::V1::PropertiesController < Api::V1::BaseController
  def download_to_csv
    authorize Property.first
    options = params.permit(
      :search_location,
      :city,
      :user_type,
      :property_type
      ) || {}
    params[:min_price].to_i == 0 ? min_price = 0 : min_price = params[:min_price].to_i
    params[:max_price].to_i == 0 ? max_price = 999999999 : max_price = params[:max_price].to_i
    params[:max_price_per_sqm].to_i == 0 ? max_price_per_sqm = 999999999 : max_price_per_sqm = params[:max_price_per_sqm].to_i
    properties_all = Property.where(options)
    properties_selected = []
    properties_all.each do |e|
      if e.price && e.livable_size_sqm && (e.price >= min_price) && (e.price <= max_price) && ((e.price / e.livable_size_sqm) <= max_price_per_sqm)
        properties_selected << e
      end
    end
    if properties_selected.empty?
      render json: { error: 'there are no records matching that request' }, status: :not_found
    else
      send_data(Property.to_csv(properties_selected), :filename => "properties.csv")
    end
  end
end
