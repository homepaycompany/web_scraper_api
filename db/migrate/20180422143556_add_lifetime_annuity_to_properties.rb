class AddLifetimeAnnuityToProperties < ActiveRecord::Migration[5.1]
  def change
    add_column :properties, :lifetime_annuity, :boolean, default: false
  end
end
