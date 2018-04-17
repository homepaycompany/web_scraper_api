class TrackingController < ApplicationController
  def redirect_to_listing
    property_id = params[:property_id]
    alert_id = params[:alert_id]
    property = Property.find(property_id)
    property_alert = PropertyAlert.find_by(alert_id: alert_id, property_id: property_id)
    property_alert.update(status: 'clicked')
    redirect_to property.urls_array.last
  end
end
