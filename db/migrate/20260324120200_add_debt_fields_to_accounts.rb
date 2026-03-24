class AddDebtFieldsToAccounts < ActiveRecord::Migration[8.1]
  def change
    add_column :accounts, :credit_limit, :decimal, precision: 12, scale: 2
    add_column :accounts, :interest_rate, :decimal, precision: 5, scale: 2
    add_column :accounts, :statement_day, :integer
    add_column :accounts, :due_day, :integer
    add_column :accounts, :minimum_payment, :decimal, precision: 12, scale: 2
    add_column :accounts, :payment_amount, :decimal, precision: 12, scale: 2
    add_column :accounts, :payment_frequency, :string
    add_column :accounts, :original_principal, :decimal, precision: 12, scale: 2
    add_column :accounts, :remaining_principal, :decimal, precision: 12, scale: 2
    add_column :accounts, :term_months, :integer
    add_column :accounts, :promo_apr_end, :date
    add_column :accounts, :next_payment_due_on, :date
    add_column :accounts, :autopay, :boolean, null: false, default: false
  end
end
