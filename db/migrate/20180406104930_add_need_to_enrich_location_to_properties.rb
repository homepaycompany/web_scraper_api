class AddNeedToEnrichLocationToProperties < ActiveRecord::Migration[5.1]
  def change
    add_column :properties, :need_to_enrich_location, :boolean, default: true
  end
end
