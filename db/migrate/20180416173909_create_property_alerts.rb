class CreatePropertyAlerts < ActiveRecord::Migration[5.1]
  def change
    create_table :property_alerts do |t|
      t.references :property, foreign_key: true
      t.references :alert, foreign_key: true

      t.timestamps
    end
  end
end
