class BudgetsController < ApplicationController
  include RecurringOccurrences

  before_action :set_budget, only: %i[show edit update destroy]

  def index
    @month = parse_month(params[:month]) || Date.current.beginning_of_month
    @month_start = @month.beginning_of_month
    @month_end = @month.end_of_month

    @budgets = Budget.includes(:category).where(month: @month).order(:category_id)
    @actuals_by_category = actuals_by_category(@month)

    @recurring_bill_occurrences = occurrences_for(
      RecurringBill.active.includes(:account, :category), @month_start, @month_end
    )
    @recurring_income_occurrences = occurrences_for(
      RecurringIncome.active.includes(:account, :category), @month_start, @month_end
    )

    @expected_income_total = @recurring_income_occurrences.sum { |o| o[:amount] }
    @expected_bill_total = @recurring_bill_occurrences.sum { |o| o[:amount] }
    @expected_net_total = @expected_income_total - @expected_bill_total

    @scheduled_bills_by_category = @recurring_bill_occurrences
      .group_by { |o| o[:record].category_id }
      .transform_values { |occurrences| occurrences.sum { |o| o[:amount] } }

    budgeted_category_ids = @budgets.map(&:category_id)
    @unbudgeted_scheduled_bills = @scheduled_bills_by_category.reject { |category_id, _| budgeted_category_ids.include?(category_id) }
    unbudgeted_ids = @unbudgeted_scheduled_bills.keys
    @unbudgeted_bill_categories = Category.where(id: unbudgeted_ids).index_by(&:id)
  end

  def show
  end

  def new
    @budget = Budget.new(month: Date.current.beginning_of_month)
  end

  def edit
  end

  def create
    @budget = Budget.new(budget_params)

    if @budget.save
      redirect_to @budget, notice: "Budget was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @budget.update(budget_params)
      redirect_to @budget, notice: "Budget was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @budget.destroy
    redirect_to budgets_url, notice: "Budget was successfully deleted."
  end

  # One screen: every expense category, prefilled with what you actually spent
  # recently (correctly averaged over however many months have real data) and
  # what's already scheduled to bill against it, editable, saved in one shot.
  def build
    @month = parse_month(params[:month]) || Date.current.beginning_of_month
    @month_start = @month.beginning_of_month
    @month_end = @month.end_of_month

    existing_by_category = Budget.where(month: @month).index_by(&:category_id)
    scheduled_by_category = occurrences_for(RecurringBill.active, @month_start, @month_end)
      .group_by { |o| o[:record].category_id }
      .transform_values { |occurrences| occurrences.sum { |o| o[:amount] } }

    @rows = suggested_budgets(@month).map do |suggestion|
      existing = existing_by_category[suggestion[:category_id]]
      suggestion.merge(
        scheduled_amount: scheduled_by_category[suggestion[:category_id]] || 0,
        current_amount: existing&.amount
      )
    end
  end

  def save_build
    month = parse_month(params[:month]) || Date.current.beginning_of_month
    saved = 0

    (params[:amounts] || {}).each do |category_id, raw_amount|
      amount = raw_amount.to_s.strip
      next if amount.blank?

      amount_value = amount.to_d
      next unless amount_value.positive?

      budget = Budget.find_or_initialize_by(category_id: category_id, month: month)
      budget.amount = amount_value
      budget.save!
      saved += 1
    end

    redirect_to budgets_path(month: month.strftime("%Y-%m")),
      notice: "Saved #{saved} #{'budget'.pluralize(saved)} for #{month.strftime('%B %Y')}."
  end

  private

  def set_budget
    @budget = Budget.find(params[:id])
  end

  def budget_params
    params.require(:budget).permit(:category_id, :month, :amount, :notes)
  end

  def parse_month(value)
    return nil if value.blank?

    raw = value.to_s.strip
    if raw.match?(/\A\d{4}-\d{2}\z/)
      year, month = raw.split("-").map(&:to_i)
      return Date.new(year, month, 1)
    end

    Date.parse(raw).beginning_of_month
  rescue ArgumentError
    nil
  end

  def actuals_by_category(month)
    start_date = month.beginning_of_month
    end_date = month.end_of_month

    Transaction.joins(:category)
      .where(categories: { kind: "expense" })
      .where(occurred_on: start_date..end_date)
      .where("amount < 0")
      .group("categories.id")
      .sum(Arel.sql("ABS(amount)"))
  end

  # Averages actual spend per category over the last few months — but divides
  # by however many of those months actually have data, not a flat 3. A
  # category with one month of history isn't secretly divided by 3.
  def suggested_budgets(month, lookback_months: 3)
    window_end = month.prev_month.end_of_month
    window_start = (window_end - (lookback_months - 1).months).beginning_of_month

    rows = Transaction.joins(:category)
      .where(categories: { kind: "expense" })
      .where(occurred_on: window_start..window_end)
      .where("amount < 0")
      .pluck("categories.id", :occurred_on, :amount)

    rows_by_category = rows.group_by { |category_id, _, _| category_id }

    Category.where(kind: "expense").order(:name).map do |category|
      category_rows = rows_by_category[category.id] || []
      months_with_data = category_rows.map { |_, occurred_on, _| occurred_on.beginning_of_month }.uniq.size
      total = category_rows.sum { |_, _, amount| amount.abs }
      average = months_with_data.positive? ? (total / months_with_data.to_f).round(2) : 0

      { category_id: category.id, category_name: category.name, amount: average, months_of_data: months_with_data }
    end
  end
end
