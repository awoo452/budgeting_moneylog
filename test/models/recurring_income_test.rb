require "test_helper"

class RecurringIncomeTest < ActiveSupport::TestCase
  def setup
    @account = Account.create!(name: "Checking", currency: "USD", opening_balance: 0)
    @category = Category.create!(name: "Paycheck", kind: "income")
  end

  test "category must be an income category" do
    expense_category = Category.create!(name: "Groceries", kind: "expense")
    income = RecurringIncome.new(
      name: "Paycheck", amount: 1000, cadence: "biweekly", next_due_on: Date.current,
      account: @account, category: expense_category
    )

    assert_not income.valid?
    assert_includes income.errors[:category], "must be an income category"
  end

  test "biweekly paycheck produces every two-week occurrence within the month" do
    income = RecurringIncome.create!(
      name: "Paycheck", amount: 1500, cadence: "biweekly", next_due_on: Date.new(2026, 7, 3),
      account: @account, category: @category
    )

    occurrences = income.occurrences_between(Date.new(2026, 7, 1), Date.new(2026, 7, 31))

    assert_equal [ Date.new(2026, 7, 3), Date.new(2026, 7, 17), Date.new(2026, 7, 31) ], occurrences
  end
end
