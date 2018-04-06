class ModifyAgentCommissionTypeOnProperties < ActiveRecord::Migration[5.1]
  def change
    remove_column :properties, :agent_commission
    add_column :properties, :agent_commission, :float
  end
end
