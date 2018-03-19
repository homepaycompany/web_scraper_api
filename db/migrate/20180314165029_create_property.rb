class CreateProperty < ActiveRecord::Migration[5.1]
  def change
    create_table :properties do |t|

      t.string :name
      t.string :description
      t.integer :price
      t.date :posted_on
      t.date :updated_on
      t.date :removed_on
      t.string :address
      t.string :property_type
      t.integer :num_floors
      t.integer :num_rooms
      t.integer :num_bedrooms
      t.integer :num_bathrooms
      t.integer :property_total_size_sqm
      t.integer :building_construction_year
      t.boolean :has_balcony
      t.boolean :has_garage
      t.boolean :has_terrace
      t.boolean :has_cellar
      t.boolean :has_parking
      t.boolean :has_elevator
      t.boolean :has_works_in_building_planned
      t.string :building_state
      t.string :property_state
      t.boolean :has_pool
      t.boolean :has_attic
      t.boolean :is_attic_convertible
      t.integer :appartment_floor
      t.integer :livable_size_sqm
      t.integer :ground_floor_size_sqm

      t.timestamps
    end
  end
end
