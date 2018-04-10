class AddingDatesToProperties < ActiveRecord::Migration[5.1]
  def change
    add_column :properties, :attributes_enriched_at, :date
    add_column :properties, :location_enriched_at, :date
  end
end
