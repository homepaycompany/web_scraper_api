class User < ApplicationRecord
  # Send email after user registration
  after_create :send_welcome_email
  has_many :alerts

  # Devise setup
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Validation rules
  validates :first_name, presence: true
  validates :last_name, presence: true

  private

  def send_welcome_email
    UserMailer.welcome(self).deliver_now
  end
end
