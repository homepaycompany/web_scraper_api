class AddPhoneNumberToProperties < ActiveRecord::Migration[5.1]
  def change
    add_column :properties, :phone_number, :string
    add_column :properties, :email, :string
  end
end
