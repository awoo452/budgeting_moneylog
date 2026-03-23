class CreateTransactions < ActiveRecord::Migration[8.1]
  def change
    create_table :transactions do |t|
      t.references :account, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
      t.date :occurred_on, null: false
      t.decimal :amount, null: false, precision: 12, scale: 2
      t.string :description, null: false
      t.string :payment_method
      t.text :notes

      t.timestamps
    end
  end
end
