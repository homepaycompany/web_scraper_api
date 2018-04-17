class AddNameToAlerts < ActiveRecord::Migration[5.1]
  def change
    add_column :alerts, :name, :string
  end
end
