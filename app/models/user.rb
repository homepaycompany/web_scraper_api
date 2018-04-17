class User < ApplicationRecord
  # Send email after user registration
  after_create :send_welcome_email
  has_many :alerts
  has_many :property_alerts, through: :alerts

  # Devise setup
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Validation rules
  validates :first_name, presence: true
  validates :last_name, presence: true

  def property_alerts_to_send
    self.property_alerts.select { |e| e.status == 'to_send' }
  end

  private

  def send_welcome_email
    UserMailer.welcome(self).deliver_now
  end
end
