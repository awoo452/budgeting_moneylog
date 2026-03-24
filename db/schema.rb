# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_03_24_123000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.string "account_type"
    t.boolean "autopay", default: false, null: false
    t.datetime "created_at", null: false
    t.decimal "credit_limit", precision: 12, scale: 2
    t.string "currency", default: "USD", null: false
    t.decimal "current_balance", precision: 12, scale: 2, default: "0.0", null: false
    t.integer "due_day"
    t.string "institution"
    t.decimal "interest_rate", precision: 5, scale: 2
    t.decimal "minimum_payment", precision: 12, scale: 2
    t.string "name", null: false
    t.date "next_payment_due_on"
    t.text "notes"
    t.date "opened_on"
    t.decimal "opening_balance", precision: 12, scale: 2, default: "0.0", null: false
    t.decimal "original_principal", precision: 12, scale: 2
    t.decimal "payment_amount", precision: 12, scale: 2
    t.string "payment_frequency"
    t.date "promo_apr_end"
    t.decimal "remaining_principal", precision: 12, scale: 2
    t.integer "statement_day"
    t.integer "term_months"
    t.datetime "updated_at", null: false
  end

  create_table "budgets", force: :cascade do |t|
    t.decimal "amount", precision: 12, scale: 2, null: false
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.date "month", null: false
    t.text "notes"
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_budgets_on_category_id"
  end

  create_table "categories", force: :cascade do |t|
    t.boolean "archived", default: false, null: false
    t.datetime "created_at", null: false
    t.string "kind", default: "expense", null: false
    t.string "name", null: false
    t.text "notes"
    t.datetime "updated_at", null: false
  end

  create_table "recurring_bills", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.boolean "active", default: true, null: false
    t.decimal "amount", precision: 12, scale: 2, null: false
    t.boolean "autopay", default: false, null: false
    t.string "cadence", null: false
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.integer "due_day"
    t.date "last_paid_on"
    t.string "name", null: false
    t.date "next_due_on", null: false
    t.text "notes"
    t.bigint "transfer_account_id"
    t.datetime "updated_at", null: false
    t.boolean "variable_amount", default: false, null: false
    t.index ["account_id"], name: "index_recurring_bills_on_account_id"
    t.index ["category_id"], name: "index_recurring_bills_on_category_id"
    t.index ["transfer_account_id"], name: "index_recurring_bills_on_transfer_account_id"
  end

  create_table "recurring_incomes", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.boolean "active", default: true, null: false
    t.decimal "amount", precision: 12, scale: 2, null: false
    t.string "cadence", null: false
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.date "next_due_on", null: false
    t.text "notes"
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_recurring_incomes_on_account_id"
    t.index ["category_id"], name: "index_recurring_incomes_on_category_id"
  end

  create_table "transactions", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.decimal "amount", precision: 12, scale: 2, null: false
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.string "description", null: false
    t.text "notes"
    t.date "occurred_on", null: false
    t.string "payment_method"
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_transactions_on_account_id"
    t.index ["category_id"], name: "index_transactions_on_category_id"
  end

  add_foreign_key "budgets", "categories"
  add_foreign_key "recurring_bills", "accounts"
  add_foreign_key "recurring_bills", "accounts", column: "transfer_account_id"
  add_foreign_key "recurring_bills", "categories"
  add_foreign_key "recurring_incomes", "accounts"
  add_foreign_key "recurring_incomes", "categories"
  add_foreign_key "transactions", "accounts"
  add_foreign_key "transactions", "categories"
end
