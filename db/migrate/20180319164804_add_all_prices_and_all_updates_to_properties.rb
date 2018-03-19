class AddAllPricesAndAllUpdatesToProperties < ActiveRecord::Migration[5.1]
  def change
    add_column :properties, :all_prices, :string
    add_column :properties, :all_updates, :string
  end
end
