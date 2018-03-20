class RemoveCreatedOnFromProperties < ActiveRecord::Migration[5.1]
  def change
    remove_column :properties, :posted_on
  end
end
