class RemoveNeedToAddToAlertsFromProperties < ActiveRecord::Migration[5.1]
  def change
    remove_column :properties, :need_to_add_to_alerts
  end
end
