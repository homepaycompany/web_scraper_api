class AddFrequencyToProperties < ActiveRecord::Migration[5.1]
  def change
    add_column :properties, :frequency_in_min, :integer, default: 59
  end
end
