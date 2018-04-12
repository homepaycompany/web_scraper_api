class AddPricePerSqmToProperties < ActiveRecord::Migration[5.1]
  def change
    add_column :properties, :price_per_sqm, :float
  end
end
