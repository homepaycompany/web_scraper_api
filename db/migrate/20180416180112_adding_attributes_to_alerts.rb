class AddingAttributesToAlerts < ActiveRecord::Migration[5.1]
  def change
    add_column :alerts, :city, :string
    add_column :alerts, :min_price, :int
    add_column :alerts, :max_price, :int
    add_column :alerts, :min_size_sqm, :int
    add_column :alerts, :max_size_sqm, :int
    add_column :alerts, :min_price_per_sqm, :float
    add_column :alerts, :max_price_per_sqm, :float
  end
end
