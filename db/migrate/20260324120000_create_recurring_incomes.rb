class CreateRecurringIncomes < ActiveRecord::Migration[8.1]
  def change
    create_table :recurring_incomes do |t|
      t.string :name, null: false
      t.decimal :amount, precision: 12, scale: 2, null: false
      t.string :cadence, null: false
      t.date :next_due_on, null: false
      t.boolean :active, null: false, default: true
      t.text :notes
      t.references :account, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true

      t.timestamps
    end
  end
end
