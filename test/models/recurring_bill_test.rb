require "test_helper"

class RecurringBillTest < ActiveSupport::TestCase
  def setup
    @account = Account.create!(name: "Checking", currency: "USD", opening_balance: 0)
    @category = Category.create!(name: "Subscriptions", kind: "expense")
  end

  def bill(cadence:, next_due_on:, amount: 10)
    RecurringBill.create!(
      name: "Test Bill",
      amount: amount,
      cadence: cadence,
      next_due_on: next_due_on,
      account: @account,
      category: @category
    )
  end

  test "transfer bills require a transfer account" do
    account = Account.create!(name: "Checking 2", currency: "USD", opening_balance: 0)
    category = Category.create!(name: "Loan Payments", kind: "transfer")

    bill = RecurringBill.new(
      name: "Loan Payment",
      amount: 25,
      cadence: "monthly",
      next_due_on: Date.current,
      account: account,
      category: category
    )

    assert_not bill.valid?
    assert_includes bill.errors[:transfer_account], "must be set for transfer bills"
  end

  test "weekly cadence produces every occurrence within the month, not just one" do
    weekly = bill(cadence: "weekly", next_due_on: Date.new(2026, 7, 1))
    occurrences = weekly.occurrences_between(Date.new(2026, 7, 1), Date.new(2026, 7, 31))

    assert_equal [ Date.new(2026, 7, 1), Date.new(2026, 7, 8), Date.new(2026, 7, 15),
                   Date.new(2026, 7, 22), Date.new(2026, 7, 29) ], occurrences
  end

  test "monthly cadence produces a single occurrence within the month" do
    monthly = bill(cadence: "monthly", next_due_on: Date.new(2026, 7, 5))
    occurrences = monthly.occurrences_between(Date.new(2026, 7, 1), Date.new(2026, 7, 31))

    assert_equal [ Date.new(2026, 7, 5) ], occurrences
  end

  test "semimonthly cadence produces two occurrences within the month" do
    semimonthly = bill(cadence: "semimonthly", next_due_on: Date.new(2026, 7, 1))
    occurrences = semimonthly.occurrences_between(Date.new(2026, 7, 1), Date.new(2026, 7, 31))

    assert_equal [ Date.new(2026, 7, 1), Date.new(2026, 7, 15) ], occurrences
  end

  test "an overdue bill catches up to the occurrence landing in the queried window" do
    overdue = bill(cadence: "monthly", next_due_on: Date.new(2026, 5, 10))
    occurrences = overdue.occurrences_between(Date.new(2026, 7, 1), Date.new(2026, 7, 31))

    assert_equal [ Date.new(2026, 7, 10) ], occurrences
  end

  test "no occurrences when next_due_on is after the window" do
    future = bill(cadence: "monthly", next_due_on: Date.new(2026, 9, 1))
    occurrences = future.occurrences_between(Date.new(2026, 7, 1), Date.new(2026, 7, 31))

    assert_equal [], occurrences
  end

  test "one_time cadence never produces more than one occurrence" do
    one_time = bill(cadence: "one_time", next_due_on: Date.new(2026, 7, 15))
    occurrences = one_time.occurrences_between(Date.new(2026, 1, 1), Date.new(2026, 12, 31))

    assert_equal [ Date.new(2026, 7, 15) ], occurrences
  end
end
