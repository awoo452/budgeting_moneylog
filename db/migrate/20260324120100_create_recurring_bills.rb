class CreateRecurringBills < ActiveRecord::Migration[8.1]
  def change
    create_table :recurring_bills do |t|
      t.string :name, null: false
      t.decimal :amount, precision: 12, scale: 2, null: false
      t.string :cadence, null: false
      t.date :next_due_on, null: false
      t.integer :due_day
      t.date :last_paid_on
      t.boolean :autopay, null: false, default: false
      t.boolean :variable_amount, null: false, default: false
      t.boolean :active, null: false, default: true
      t.text :notes
      t.references :account, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true

      t.timestamps
    end
  end
end
