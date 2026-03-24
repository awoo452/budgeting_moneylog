require "test_helper"

class RecurringBillTest < ActiveSupport::TestCase
  test "transfer bills require a transfer account" do
    account = Account.create!(name: "Checking", currency: "USD", opening_balance: 0)
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
end
