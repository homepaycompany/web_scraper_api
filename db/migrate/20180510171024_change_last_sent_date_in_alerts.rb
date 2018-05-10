class ChangeLastSentDateInAlerts < ActiveRecord::Migration[5.1]
  def change
    remove_column :alerts, :last_sent_date
    add_column :alerts, :last_sent_date, :datetime
  end
end
