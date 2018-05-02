class AddDefaultsToAlerts < ActiveRecord::Migration[5.1]
  def change
    remove_column :alerts, :min_number_of_rooms
    remove_column :alerts, :max_number_of_rooms
    add_column :alerts, :min_number_of_rooms, :integer, default: 0
    add_column :alerts, :max_number_of_rooms, :integer, default: 999999999
  end
end
