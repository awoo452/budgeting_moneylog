class RecurringBillsController < ApplicationController
  before_action :set_recurring_bill, only: %i[show edit update destroy apply_payment]

  def index
    @recurring_bills = RecurringBill.includes(:account, :category).order(:next_due_on, :name)
  end

  def show
  end

  def new
    @recurring_bill = RecurringBill.new(next_due_on: Date.current, cadence: "monthly", active: true)
  end

  def edit
  end

  def create
    @recurring_bill = RecurringBill.new(recurring_bill_params)
    assign_associations(@recurring_bill)

    if @recurring_bill.save
      redirect_to @recurring_bill, notice: "Recurring bill was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    assign_associations(@recurring_bill)

    if @recurring_bill.update(recurring_bill_params)
      redirect_to @recurring_bill, notice: "Recurring bill was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @recurring_bill.destroy
    redirect_to recurring_bills_url, notice: "Recurring bill was successfully deleted."
  end

  def apply_payment
    applied_on = parse_date_param(params[:occurred_on]) || @recurring_bill.next_due_on || Date.current
    amount = @recurring_bill.amount.abs

    ActiveRecord::Base.transaction do
      Transaction.create!(
        account: @recurring_bill.account,
        category: @recurring_bill.category,
        occurred_on: applied_on,
        amount: -amount,
        description: "Recurring bill: #{@recurring_bill.name}",
        notes: payment_notes_for(@recurring_bill, inbound: false)
      )
      @recurring_bill.account.update!(current_balance: @recurring_bill.account.current_balance - amount)

      if @recurring_bill.transfer_account
        Transaction.create!(
          account: @recurring_bill.transfer_account,
          category: @recurring_bill.category,
          occurred_on: applied_on,
          amount: amount,
          description: "Recurring payment: #{@recurring_bill.name}",
          notes: payment_notes_for(@recurring_bill, inbound: true)
        )
        @recurring_bill.transfer_account.update!(current_balance: @recurring_bill.transfer_account.current_balance + amount)
      end

      @recurring_bill.last_paid_on = applied_on
      @recurring_bill.next_due_on = @recurring_bill.next_due_on_after(@recurring_bill.next_due_on)
      @recurring_bill.active = false if @recurring_bill.cadence == "one_time"
      @recurring_bill.save!
    end

    redirect_to recurring_bills_url, notice: "Applied payment for #{@recurring_bill.name}."
  end

  private

  def set_recurring_bill
    @recurring_bill = RecurringBill.find(params[:id])
  end

  def recurring_bill_params
    params.require(:recurring_bill).permit(:name, :amount, :cadence, :next_due_on, :due_day, :last_paid_on,
                                           :autopay, :variable_amount, :active, :notes)
  end

  def assign_associations(recurring_bill)
    account_id = params.dig(:recurring_bill, :account_id)
    category_id = params.dig(:recurring_bill, :category_id)
    transfer_account_id = params.dig(:recurring_bill, :transfer_account_id)

    recurring_bill.account = Account.find_by(id: account_id) if account_id.present?
    recurring_bill.category = Category.find_by(id: category_id) if category_id.present?
    if transfer_account_id.present?
      recurring_bill.transfer_account = Account.find_by(id: transfer_account_id)
    else
      recurring_bill.transfer_account = nil
    end
  end

  def parse_date_param(value)
    return nil if value.blank?

    Date.parse(value)
  rescue ArgumentError
    nil
  end

  def payment_notes_for(bill, inbound:)
    return nil unless bill.transfer_account

    if inbound
      "From #{bill.account.name}"
    else
      "To #{bill.transfer_account.name}"
    end
  end
end
