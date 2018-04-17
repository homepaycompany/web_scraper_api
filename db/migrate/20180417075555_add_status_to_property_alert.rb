class AddStatusToPropertyAlert < ActiveRecord::Migration[5.1]
  def change
    add_column :property_alerts, :status, :string, default: 'to_send'
  end
end
