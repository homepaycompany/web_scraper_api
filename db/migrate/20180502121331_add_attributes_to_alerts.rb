class AddAttributesToAlerts < ActiveRecord::Migration[5.1]
  def change
    add_column :alerts, :min_number_of_rooms, :integer
    add_column :alerts, :max_number_of_rooms, :integer
  end
end
