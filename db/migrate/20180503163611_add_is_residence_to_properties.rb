class AddIsResidenceToProperties < ActiveRecord::Migration[5.1]
  def change
    add_column :properties, :is_residence, :boolean, default: false
  end
end
