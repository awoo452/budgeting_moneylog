class BudgetsController < ApplicationController
  before_action :set_budget, only: %i[show edit update destroy]

  def index
    @month = parse_month(params[:month]) || Date.current.beginning_of_month
    @budgets = Budget.includes(:category).where(month: @month).order(:category_id)
    @actuals_by_category = actuals_by_category(@month)
    @suggested_budgets = suggested_budgets(@month)
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

  def generate
    month = parse_month(params[:month]) || Date.current.beginning_of_month
    suggestions = suggested_budgets(month)
    created = 0

    suggestions.each do |suggestion|
      next if suggestion[:amount].zero?

      budget = Budget.find_or_initialize_by(category_id: suggestion[:category_id], month: month)
      budget.amount = suggestion[:amount]
      budget.notes = "Suggested from last 3 months average."
      created += 1 if budget.new_record?
      budget.save!
    end

    redirect_to budgets_path(month: month), notice: "Generated #{created} budgets for #{month}."
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

    Date.parse(value).beginning_of_month
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

  def suggested_budgets(month)
    window_months = 3
    window_end = month.prev_month.end_of_month
    window_start = (window_end - (window_months - 1).months).beginning_of_month

    sums = Transaction.joins(:category)
      .where(categories: { kind: "expense" })
      .where(occurred_on: window_start..window_end)
      .where("amount < 0")
      .group("categories.id", "categories.name")
      .sum(Arel.sql("ABS(amount)"))

    categories = Category.where(kind: "expense").order(:name)
    categories.map do |category|
      total = sums.fetch([ category.id, category.name ], 0)
      average = (total / window_months.to_f).round(2)
      { category_id: category.id, category_name: category.name, amount: average }
    end
  end
end
