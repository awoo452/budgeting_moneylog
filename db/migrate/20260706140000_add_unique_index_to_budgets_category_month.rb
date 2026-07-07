class AddUniqueIndexToBudgetsCategoryMonth < ActiveRecord::Migration[8.1]
  def change
    add_index :budgets, [ :category_id, :month ], unique: true
  end
end
