class PropertyAlert < ApplicationRecord
  belongs_to :property
  belongs_to :alert
end
