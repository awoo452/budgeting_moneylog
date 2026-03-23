class DashboardController < ApplicationController
  def index
    @start_date = parse_date_param(params[:start_date])
    @end_date = parse_date_param(params[:end_date])

    scope = Transaction.includes(:category)
    scope = scope.where("occurred_on >= ?", @start_date) if @start_date
    scope = scope.where("occurred_on <= ?", @end_date) if @end_date

    @transaction_count = scope.count
    @income_total = scope.where("amount > 0").sum(:amount)
    @expense_total = scope.where("amount < 0").sum(Arel.sql("ABS(amount)"))
    @net_total = @income_total - @expense_total

    @expense_by_category = scope
      .joins(:category)
      .where("amount < 0")
      .group("categories.name")
      .sum(Arel.sql("ABS(amount)"))
      .sort_by { |_, total| -total }

    @income_by_category = scope
      .joins(:category)
      .where("amount > 0")
      .group("categories.name")
      .sum(:amount)
      .sort_by { |_, total| -total }
  end

  private

  def parse_date_param(value)
    return nil if value.blank?

    Date.parse(value)
  rescue ArgumentError
    nil
  end
end
