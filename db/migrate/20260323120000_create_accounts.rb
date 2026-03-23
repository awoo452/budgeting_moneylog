class CreateAccounts < ActiveRecord::Migration[8.1]
  def change
    create_table :accounts do |t|
      t.string :name, null: false
      t.string :institution
      t.string :account_type
      t.string :currency, null: false, default: "USD"
      t.decimal :opening_balance, null: false, precision: 12, scale: 2, default: 0
      t.date :opened_on
      t.text :notes

      t.timestamps
    end
  end
end
