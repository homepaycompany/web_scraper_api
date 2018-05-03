class AddNeedToCheckForDuplicatesToProperties < ActiveRecord::Migration[5.1]
  def change
    add_column :properties, :need_to_check_for_duplicates, :boolean, default: true
  end
end
