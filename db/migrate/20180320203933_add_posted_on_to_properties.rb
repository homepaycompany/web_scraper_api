class AddPostedOnToProperties < ActiveRecord::Migration[5.1]
  def change
    add_column :properties, :posted_on, :date
  end
end
