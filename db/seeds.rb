# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

today = Date.current
month_start = today.beginning_of_month

checking = Account.find_or_create_by!(name: "Everyday Checking") do |account|
  account.institution = "Local Bank"
  account.account_type = "checking"
  account.currency = "USD"
  account.opening_balance = 1500
  account.opened_on = month_start - 120
  account.notes = "Primary spending account."
end

savings = Account.find_or_create_by!(name: "Emergency Savings") do |account|
  account.institution = "Local Bank"
  account.account_type = "savings"
  account.currency = "USD"
  account.opening_balance = 5000
  account.opened_on = month_start - 365
  account.notes = "Emergency fund."
end

income = Category.find_or_create_by!(name: "Income", kind: "income") do |category|
  category.notes = "Salary and other income."
end

groceries = Category.find_or_create_by!(name: "Groceries", kind: "expense") do |category|
  category.notes = "Food and household basics."
end

rent = Category.find_or_create_by!(name: "Rent", kind: "expense") do |category|
  category.notes = "Monthly rent or mortgage."
end

transportation = Category.find_or_create_by!(name: "Transportation", kind: "expense") do |category|
  category.notes = "Gas, transit, rideshare."
end

Budget.find_or_create_by!(category: groceries, month: month_start) do |budget|
  budget.amount = 450
  budget.notes = "Monthly grocery target."
end

Budget.find_or_create_by!(category: rent, month: month_start) do |budget|
  budget.amount = 1800
  budget.notes = "Monthly rent target."
end

Budget.find_or_create_by!(category: transportation, month: month_start) do |budget|
  budget.amount = 200
  budget.notes = "Monthly transportation target."
end

Transaction.find_or_create_by!(
  account: checking,
  category: income,
  occurred_on: month_start + 1,
  amount: 3200,
  description: "Paycheck"
) do |transaction|
  transaction.payment_method = "Direct deposit"
  transaction.notes = "Monthly salary."
end

Transaction.find_or_create_by!(
  account: checking,
  category: rent,
  occurred_on: month_start + 2,
  amount: -1800,
  description: "Rent payment"
) do |transaction|
  transaction.payment_method = "ACH"
  transaction.notes = "Paid landlord."
end

Transaction.find_or_create_by!(
  account: checking,
  category: groceries,
  occurred_on: month_start + 5,
  amount: -128.45,
  description: "Grocery run"
) do |transaction|
  transaction.payment_method = "Debit card"
  transaction.notes = "Weekly groceries."
end

Transaction.find_or_create_by!(
  account: checking,
  category: transportation,
  occurred_on: month_start + 8,
  amount: -45.75,
  description: "Gas"
) do |transaction|
  transaction.payment_method = "Debit card"
  transaction.notes = "Fuel refill."
end

Transaction.find_or_create_by!(
  account: savings,
  category: income,
  occurred_on: month_start + 10,
  amount: 200,
  description: "Savings transfer"
) do |transaction|
  transaction.payment_method = "Transfer"
  transaction.notes = "Monthly savings contribution."
end
