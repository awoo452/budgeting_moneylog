require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  def setup
    @account = Account.create!(name: "Checking", currency: "USD", opening_balance: 0)
    @bill_category = Category.create!(name: "Subscriptions", kind: "expense")
  end

  test "upcoming bill total reflects every occurrence this month, not just one" do
    travel_to Date.new(2026, 7, 10) do
      RecurringBill.create!(
        name: "Streaming", amount: 10, cadence: "weekly", next_due_on: Date.new(2026, 7, 1),
        account: @account, category: @bill_category
      )

      get dashboard_url

      assert_response :success
      assert_match(/Expected bills:.*\$50\.00/m, response.body)
    end
  end
end
