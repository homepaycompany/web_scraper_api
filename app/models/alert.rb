class Alert < ApplicationRecord
  belongs_to :user
  has_many :property_alerts, dependent: :destroy
  has_many :properties, through: :property_alerts
  validates :user, uniqueness: { scope: [:zipcode, :city, :min_price, :max_price, :min_size_sqm, :max_size_sqm, :min_price_per_sqm, :max_price_per_sqm, :min_number_of_rooms, :max_number_of_rooms] }
  # after_create :send_alert_email

  def properties_to_send
    self.property_alerts.select { |e| e.status == 'to_send' }.map { |e| e.property }
  end

  def property_alerts_to_send
    self.property_alerts.select { |e| e.status == 'to_send' }
  end

  # def send_alert_email
  #   SendOneAlertWorker.perform_async(self.id)
  # end
end
