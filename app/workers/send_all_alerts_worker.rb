class SendAllAlertsWorker
  include Sidekiq::Worker

  def perform
    Alert.all.each do |alert|
      options = {}
      options[:status] = 'open'
      options[:lifetime_annuity] = false
      options[:price] = [alert.min_price..alert.max_price]
      options[:livable_size_sqm] = [alert.min_size_sqm..alert.max_size_sqm]
      options[:price_per_sqm] = [alert.min_price_per_sqm..alert.max_price_per_sqm]
      options[:num_rooms] = [alert.min_number_of_rooms..alert.max_number_of_rooms]
      options[:city] = alert.city.downcase unless alert.city.nil?
      options[:zipcode] = alert.zipcode unless alert.zipcode.nil?
      Property.where(options).pluck(:id).each do |property_id|
        PropertyAlert.create(alert: alert, property_id: property_id) unless alert.user.properties.include?(Property.find(property_id))
      end
    end
    User.all.pluck(:id).each do |user_id|
      send_alert_email(user_id)
    end
  end

  def send_alert_email(user_id)
    UserMailer.alert(user_id).deliver_now
  end
end


