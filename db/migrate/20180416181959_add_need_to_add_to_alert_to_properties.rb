class AddNeedToAddToAlertToProperties < ActiveRecord::Migration[5.1]
  def change
    add_column :properties, :need_to_add_to_alerts, :boolean, default: true
  end
end
