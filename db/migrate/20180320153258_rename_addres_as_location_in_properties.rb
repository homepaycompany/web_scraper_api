class RenameAddresAsLocationInProperties < ActiveRecord::Migration[5.1]
  def change
    rename_column :properties, :address, :location
  end
end
