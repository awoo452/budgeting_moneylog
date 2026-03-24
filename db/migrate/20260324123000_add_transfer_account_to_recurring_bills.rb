class AddTransferAccountToRecurringBills < ActiveRecord::Migration[8.1]
  def change
    add_reference :recurring_bills, :transfer_account, foreign_key: { to_table: :accounts }
  end
end
