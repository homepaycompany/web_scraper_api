class AddAgentCommissionToProperties < ActiveRecord::Migration[5.1]
  def change
    add_column :properties, :agent_commission, :integer
  end
end
