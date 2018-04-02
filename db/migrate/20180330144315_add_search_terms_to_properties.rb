class AddSearchTermsToProperties < ActiveRecord::Migration[5.1]
  def change
    add_column :properties, :search_location, :string
  end
end
