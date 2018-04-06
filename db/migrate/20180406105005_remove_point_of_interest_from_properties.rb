class RemovePointOfInterestFromProperties < ActiveRecord::Migration[5.1]
  def change
    remove_column :properties, :point_of_interest
  end
end
