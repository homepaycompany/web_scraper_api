class SendOneAlertWorker
  include Sidekiq::Worker

  def perform(alert_id)
    alert = Alert.find(alert_id)
    Property.where(
      status: 'open',
      city: alert.city,
      price: [alert.min_price..alert.max_price],
      livable_size_sqm: [alert.min_size_sqm..alert.max_size_sqm],
      price_per_sqm: [alert.min_price_per_sqm..alert.max_price_per_sqm]
    ).each do |property|
      PropertyAlert.create(alert: alert, property: property)
    end
    send_alert_email(alert.user) unless alert.user.alerts.empty? || alert.user.property_alerts_to_send.empty?
  end

  def send_alert_email(user)
    UserMailer.alert(user, user.alerts).deliver_now
  end
end


