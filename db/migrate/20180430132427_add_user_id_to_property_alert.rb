class AddUserIdToPropertyAlert < ActiveRecord::Migration[5.1]
  def change
    add_column :property_alerts, :user_id, :integer
  end
end
