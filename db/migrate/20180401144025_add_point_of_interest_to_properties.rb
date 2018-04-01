class AddPointOfInterestToProperties < ActiveRecord::Migration[5.1]
  def change
    add_column :properties, :point_of_interest, :string
  end
end
