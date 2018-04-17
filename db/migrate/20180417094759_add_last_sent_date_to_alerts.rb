class AddLastSentDateToAlerts < ActiveRecord::Migration[5.1]
  def change
    add_column :alerts, :last_sent_date, :date
  end
end
