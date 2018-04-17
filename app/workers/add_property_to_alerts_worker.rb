class AddPropertyToAlertsWorker
  include Sidekiq::Worker

  def perform
    Property.where(need_to_add_to_alerts: true).each do |property|
      p "Adding property - #{property.id}"
      add_property_to_alerts(property)
      property.update(need_to_add_to_alerts: false)
    end
    User.all.each do |user|
      send_alert_email(user) unless user.alerts.empty? || user.property_alerts_to_send.empty?
    end
  end

  def add_property_to_alerts(property)
    Alert.where(
      city: property.city,
      min_price: [0..property.price],
      max_price: [property.price..999999999],
      min_size_sqm: [0..property.livable_size_sqm],
      max_size_sqm: [property.livable_size_sqm..999999999],
      min_price_per_sqm: [0..property.price_per_sqm],
      max_price_per_sqm: [property.price_per_sqm..999999999]
    ).each do |alert|
      PropertyAlert.create(alert: alert, property: property)
    end
  end

  def send_alert_email(user)
    UserMailer.alert(user, user.alerts).deliver_now
  end
end
