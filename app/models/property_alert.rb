class PropertyAlert < ApplicationRecord
  belongs_to :property
  belongs_to :alert
  validates :alert, uniqueness: { scope: :property }
  after_create :add_user_id

  def add_user_id
    self.update(user_id: self.alert.user_id)
  end
end
