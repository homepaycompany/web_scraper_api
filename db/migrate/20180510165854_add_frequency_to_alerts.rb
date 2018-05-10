class AddFrequencyToAlerts < ActiveRecord::Migration[5.1]
  def change
    remove_column :properties, :frequency_in_min
    add_column :alerts, :frequency_in_min, :integer, default: 59
  end
end
