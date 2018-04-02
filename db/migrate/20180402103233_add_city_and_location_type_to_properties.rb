class AddCityAndLocationTypeToProperties < ActiveRecord::Migration[5.1]
  def change
    add_column :properties, :city, :string
    add_column :properties, :location_type, :string
  end
end
