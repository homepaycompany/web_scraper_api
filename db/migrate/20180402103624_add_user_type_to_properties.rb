class AddUserTypeToProperties < ActiveRecord::Migration[5.1]
  def change
    add_column :properties, :user_type, :string
  end
end
