require "test_helper"

class BudgetTest < ActiveSupport::TestCase
  def setup
    @expense_category = Category.create!(name: "Groceries", kind: "expense")
  end

  test "month is normalized to the beginning of the month regardless of the day submitted" do
    budget = Budget.create!(category: @expense_category, month: Date.new(2026, 7, 15), amount: 100)

    assert_equal Date.new(2026, 7, 1), budget.month
  end

  test "a second budget for the same category and month is invalid" do
    Budget.create!(category: @expense_category, month: Date.new(2026, 7, 1), amount: 100)
    dup = Budget.new(category: @expense_category, month: Date.new(2026, 7, 20), amount: 50)

    assert_not dup.valid?
    assert_includes dup.errors[:category_id], "has already been taken"
  end

  test "a different month for the same category is fine" do
    Budget.create!(category: @expense_category, month: Date.new(2026, 7, 1), amount: 100)
    other_month = Budget.new(category: @expense_category, month: Date.new(2026, 8, 1), amount: 100)

    assert other_month.valid?
  end

  test "amount must be greater than zero" do
    zero = Budget.new(category: @expense_category, month: Date.new(2026, 7, 1), amount: 0)
    negative = Budget.new(category: @expense_category, month: Date.new(2026, 7, 1), amount: -50)

    assert_not zero.valid?
    assert_not negative.valid?
  end

  test "category must be an expense category" do
    income_category = Category.create!(name: "Paycheck", kind: "income")
    budget = Budget.new(category: income_category, month: Date.new(2026, 7, 1), amount: 100)

    assert_not budget.valid?
    assert_includes budget.errors[:category], "must be an expense category"
  end
end
