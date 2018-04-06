class AddingFieldsToProperties < ActiveRecord::Migration[5.1]
  def change
    add_column :properties, :need_to_enrich_attributes, :boolean, default: true
    add_column :properties, :size_balcony_sqm, :float
    add_column :properties, :size_terrace_sqm, :float
    add_column :properties, :size_cellar_sqm, :float
    add_column :properties, :sold_rented, :boolean
  end
end
