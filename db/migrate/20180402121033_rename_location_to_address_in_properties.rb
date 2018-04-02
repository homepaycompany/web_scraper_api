class RenameLocationToAddressInProperties < ActiveRecord::Migration[5.1]
  def change
    rename_column :properties, :location, :address
  end
end
