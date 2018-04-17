class AddDefaultToAlertsAttributes < ActiveRecord::Migration[5.1]
  def change
    change_column :alerts, :min_price, :int, default: 0
    change_column :alerts, :max_price, :int, default: 999999999
    change_column :alerts, :min_size_sqm, :int, default: 0
    change_column :alerts, :max_size_sqm, :int, default: 999999999
    change_column :alerts, :min_price_per_sqm, :float, default: 0
    change_column :alerts, :max_price_per_sqm, :float, default: 999999999
  end
end
