class AddUserToAlerts < ActiveRecord::Migration[5.1]
  def change
    add_reference :alerts, :user, foreign_key: true
  end
end
