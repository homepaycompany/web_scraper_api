class SendAllAlertsWorker
  include Sidekiq::Worker

  def perform
    properties = Property.where(status: 'open')
    Alert.all.select { |e| e.last_sent_date.nil? || e.last_sent_date < Date.today }.each do |alert|
      properties.where(
        city: alert.city,
        price: [alert.min_price..alert.max_price],
        livable_size_sqm: [alert.min_size_sqm..alert.max_size_sqm],
        price_per_sqm: [alert.min_price_per_sqm..alert.max_price_per_sqm]
      ).each do |property|
        PropertyAlert.create(alert: alert, property: property) unless alert.user.properties.include?(property)
      end
    end
    User.all.each do |user|
      send_alert_email(user) unless user.alerts.empty? || user.property_alerts_to_send.empty?
    end
  end

  def send_alert_email(user)
    UserMailer.alert(user, user.alerts).deliver_now
  end
end


