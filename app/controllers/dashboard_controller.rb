class DashboardController < ApplicationController
  def index
    @start_date = parse_date_param(params[:start_date])
    @end_date = parse_date_param(params[:end_date])

    scope = Transaction.includes(:category)
    scope = scope.where("occurred_on >= ?", @start_date) if @start_date
    scope = scope.where("occurred_on <= ?", @end_date) if @end_date

    @transaction_count = scope.count

    expense_scope = scope.joins(:category).where(categories: { kind: "expense" })
    income_scope = scope.joins(:category).where(categories: { kind: "income" })

    @income_total = income_scope.where("amount > 0").sum(:amount)
    @expense_total = expense_scope.where("amount < 0").sum(Arel.sql("ABS(amount)"))
    @net_total = @income_total - @expense_total

    @expense_by_category = expense_scope
      .where("amount < 0")
      .group("categories.id", "categories.name")
      .sum(Arel.sql("ABS(amount)"))
      .map { |(id, name), total| { id: id, name: name, total: total } }
      .sort_by { |row| -row[:total] }

    @income_by_category = income_scope
      .where("amount > 0")
      .group("categories.id", "categories.name")
      .sum(:amount)
      .map { |(id, name), total| { id: id, name: name, total: total } }
      .sort_by { |row| -row[:total] }

    @forecast_start = Date.current.beginning_of_month
    @forecast_end = (@forecast_start.next_month - 1.day)

    @upcoming_incomes = RecurringIncome.active
      .includes(:account, :category)
      .where(next_due_on: @forecast_start..@forecast_end)
      .order(:next_due_on, :name)

    @upcoming_bills = RecurringBill.active
      .includes(:account, :category)
      .where(next_due_on: @forecast_start..@forecast_end)
      .order(:next_due_on, :name)

    @upcoming_income_total = @upcoming_incomes.sum(:amount)
    @upcoming_bill_total = @upcoming_bills.sum(:amount)
  end

  private

  def parse_date_param(value)
    return nil if value.blank?

    Date.parse(value)
  rescue ArgumentError
    nil
  end
end
