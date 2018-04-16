class AddPropertyToAlertWorker
  include Sidekiq::Worker

  def perform
    properties = Property.where(need_to_add_to_alerts: true)
    properties.each do |property|
      add_property_to_alert(property)
      property.update(need_to_add_to_alerts: false)
    end
  end

  def add_property_to_alert(property)
    alerts = Alert.each do |alert|
      if (
        property.city == alert.city
        property.price > alert.min_price &&
        property.price < alert.max_price &&
        property.livable_size_sqm > alert.min_size_sqm &&
        property.livable_size_sqm < alert.max_size_sqm &&
        property.price_per_sqm > alert.min_price_per_sqm &&
        property.price_per_sqm < alert.max_price_per_sqm
      )
        PropertyAlert.create(alert: alert, property: property)
      end
    end
  end
end
