class AddCurrentBalanceToAccounts < ActiveRecord::Migration[8.1]
  def change
    add_column :accounts, :current_balance, :decimal, precision: 12, scale: 2, default: 0.0, null: false
  end
end
