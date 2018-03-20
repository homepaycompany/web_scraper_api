class AddUrlsToProperties < ActiveRecord::Migration[5.1]
  def change
    add_column :properties, :urls, :string
  end
end
