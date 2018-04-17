class PropertyAlert < ApplicationRecord
  belongs_to :property
  belongs_to :alert
  validates :alert, uniqueness: { scope: :property }
end
