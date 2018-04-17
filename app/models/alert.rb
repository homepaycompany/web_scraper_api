class Alert < ApplicationRecord
  belongs_to :user
  has_many :property_alerts
  has_many :properties, through: :property_alerts
  validates :city, :name, presence: true

  def properties_to_send
    self.property_alerts.select { |e| e.status == 'to_send' }.map { |e| e.property }
  end

  def property_alerts_to_send
    self.property_alerts.select { |e| e.status == 'to_send' }
  end
end
