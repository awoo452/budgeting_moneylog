class CreateCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :categories do |t|
      t.string :name, null: false
      t.string :kind, null: false, default: "expense"
      t.boolean :archived, null: false, default: false
      t.text :notes

      t.timestamps
    end
  end
end
