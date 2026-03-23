class CreateBudgets < ActiveRecord::Migration[8.1]
  def change
    create_table :budgets do |t|
      t.references :category, null: false, foreign_key: true
      t.date :month, null: false
      t.decimal :amount, null: false, precision: 12, scale: 2
      t.text :notes

      t.timestamps
    end
  end
end
