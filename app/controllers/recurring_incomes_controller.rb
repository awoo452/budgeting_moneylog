class RecurringIncomesController < ApplicationController
  before_action :set_recurring_income, only: %i[show edit update destroy]

  def index
    @recurring_incomes = RecurringIncome.includes(:account, :category).order(:next_due_on, :name)
  end

  def show
  end

  def new
    @recurring_income = RecurringIncome.new(next_due_on: Date.current, cadence: "monthly", active: true)
  end

  def edit
  end

  def create
    @recurring_income = RecurringIncome.new(recurring_income_params)
    assign_associations(@recurring_income)

    if @recurring_income.save
      redirect_to @recurring_income, notice: "Recurring income was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    assign_associations(@recurring_income)

    if @recurring_income.update(recurring_income_params)
      redirect_to @recurring_income, notice: "Recurring income was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @recurring_income.destroy
    redirect_to recurring_incomes_url, notice: "Recurring income was successfully deleted."
  end

  private

  def set_recurring_income
    @recurring_income = RecurringIncome.find(params[:id])
  end

  def recurring_income_params
    params.require(:recurring_income).permit(:name, :amount, :cadence, :next_due_on, :active, :notes)
  end

  def assign_associations(recurring_income)
    account_id = params.dig(:recurring_income, :account_id)
    category_id = params.dig(:recurring_income, :category_id)

    recurring_income.account = Account.find_by(id: account_id) if account_id.present?
    recurring_income.category = Category.find_by(id: category_id) if category_id.present?
  end
end
