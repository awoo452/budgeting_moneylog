require "test_helper"

class BudgetsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @account = Account.create!(name: "Checking", currency: "USD", opening_balance: 0)
    @category = Category.create!(name: "Subscriptions", kind: "expense")
  end

  test "expected bill total reflects every occurrence in the month, not just one" do
    RecurringBill.create!(
      name: "Streaming", amount: 10, cadence: "weekly", next_due_on: Date.new(2026, 7, 1),
      account: @account, category: @category
    )

    get budgets_url(month: "2026-07")

    assert_response :success
    assert_match(/Expected bills:.*\$50\.00/m, response.body)
  end

  test "an overdue recurring bill still counts toward the current month" do
    RecurringBill.create!(
      name: "Gym", amount: 30, cadence: "monthly", next_due_on: Date.new(2026, 4, 15),
      account: @account, category: @category
    )

    get budgets_url(month: "2026-07")

    assert_match(/Expected bills:.*\$30\.00/m, response.body)
  end

  test "scheduled bills without a budget show the summed total for that category" do
    RecurringBill.create!(
      name: "Streaming", amount: 10, cadence: "weekly", next_due_on: Date.new(2026, 7, 1),
      account: @account, category: @category
    )

    get budgets_url(month: "2026-07")

    assert_match "Scheduled bills without a budget", response.body
    assert_match "$50.00", response.body
  end

  # ── build ────────────────────────────────────────────────

  test "build averages by months that actually have data, not a flat 3" do
    Transaction.create!(
      account: @account, category: @category, occurred_on: Date.new(2026, 6, 15),
      amount: -300, description: "Groceries"
    )

    get build_budgets_url(month: "2026-07")

    assert_response :success
    assert_match "$300.00", response.body
    assert_no_match "$100.00", response.body
  end

  test "build shows no history yet for a category with no recent transactions" do
    get build_budgets_url(month: "2026-07")

    assert_match "No history yet", response.body
  end

  test "build shows the scheduled bill total for a category" do
    RecurringBill.create!(
      name: "Streaming", amount: 15, cadence: "monthly", next_due_on: Date.new(2026, 7, 5),
      account: @account, category: @category
    )

    get build_budgets_url(month: "2026-07")

    assert_match "$15.00", response.body
  end

  # ── save_build ───────────────────────────────────────────

  test "save_build creates a budget from a submitted amount" do
    assert_difference "Budget.count", 1 do
      patch save_build_budgets_url, params: { month: "2026-07", amounts: { @category.id => "250.00" } }
    end

    budget = Budget.sole
    assert_equal @category, budget.category
    assert_equal Date.new(2026, 7, 1), budget.month
    assert_equal 250.00, budget.amount
    assert_redirected_to budgets_url(month: "2026-07")
  end

  test "save_build skips blank amounts" do
    assert_no_difference "Budget.count" do
      patch save_build_budgets_url, params: { month: "2026-07", amounts: { @category.id => "" } }
    end
  end

  test "save_build skips zero and negative amounts" do
    other = Category.create!(name: "Other", kind: "expense")

    assert_no_difference "Budget.count" do
      patch save_build_budgets_url, params: {
        month: "2026-07",
        amounts: { @category.id => "0", other.id => "-10" }
      }
    end
  end

  test "save_build updates an existing budget instead of duplicating it" do
    Budget.create!(category: @category, month: Date.new(2026, 7, 1), amount: 100)

    assert_no_difference "Budget.count" do
      patch save_build_budgets_url, params: { month: "2026-07", amounts: { @category.id => "175.00" } }
    end

    assert_equal 175.00, Budget.sole.amount
  end
end
