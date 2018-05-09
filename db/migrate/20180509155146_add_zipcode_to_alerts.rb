class AddZipcodeToAlerts < ActiveRecord::Migration[5.1]
  def change
    add_column :alerts, :zipcode, :integer
  end
end
