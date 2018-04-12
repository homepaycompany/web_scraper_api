class Api::V1::PropertiesController < Api::V1::BaseController
  def download_to_csv
    authorize Property.first
    options = property_params
    properties = Property.where(options)
    if properties.empty?
      render json: { error: 'there are no records matching that request' }, status: :not_found
    else
      send_data(Property.to_csv(properties), :filename => "properties.csv")
    end
  end

  private

  def property_params
    min_price = params[:min_price].to_i
    min_livable_size_sqm = params[:min_livable_size_sqm].to_i
    min_price_per_sqm = params[:min_price_per_sqm].to_i
    params[:max_price].to_i == 0 ? max_price = 999999999 : max_price = params[:max_price].to_i
    params[:max_livable_size_sqm].to_i == 0 ? max_livable_size_sqm = 999999999 : max_livable_size_sqm = params[:max_livable_size_sqm].to_i
    params[:max_price_per_sqm].to_i == 0 ? max_price_per_sqm = 999999999 : max_price_per_sqm = params[:max_price_per_sqm].to_i
    return params.permit(
      :search_location,
      :city,
      :user_type,
      :property_type,
      :status
    ).merge(
      price: [min_price..max_price],
      livable_size_sqm: [min_livable_size_sqm..max_livable_size_sqm],
      price_per_sqm: [min_price_per_sqm..max_price_per_sqm]
    )
  end
end
