class TransactionsController < ApplicationController
  require "date"
  require "bigdecimal"
  require "csv"
  before_action :set_transaction, only: %i[show edit update destroy]

  def index
    @transactions = Transaction.includes(:account, :category).order(occurred_on: :desc, created_at: :desc)
  end

  def show
  end

  def new
    @transaction = Transaction.new(occurred_on: Date.current)
  end

  def edit
  end

  def create
    @transaction = Transaction.new(transaction_params)
    assign_associations(@transaction)

    if @transaction.save
      redirect_to @transaction, notice: "Transaction was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    assign_associations(@transaction)

    if @transaction.update(transaction_params)
      redirect_to @transaction, notice: "Transaction was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @transaction.destroy
    redirect_to transactions_url, notice: "Transaction was successfully deleted."
  end

  def import
    @accounts = Account.order(:name)
    @import_errors = []
  end

  def import_create
    @accounts = Account.order(:name)
    @import_errors = []
    account = Account.find_by(id: params[:account_id])
    file = params[:csv_file]

    unless account && file
      @import_errors << "Select an account and choose a CSV file to upload."
      render :import, status: :unprocessable_entity
      return
    end

    result = import_transactions(file, account)
    @import_errors = result[:errors]

    if @import_errors.any?
      flash.now[:alert] = "Imported #{result[:created]} transactions with #{result[:errors].size} issues."
      render :import, status: :unprocessable_entity
    else
      redirect_to transactions_path, notice: "Imported #{result[:created]} transactions."
    end
  end

  private

  def set_transaction
    @transaction = Transaction.find(params[:id])
  end

  def transaction_params
    params.require(:transaction).permit(:occurred_on, :amount, :description, :payment_method, :notes)
  end

  def import_transactions(file, account)
    income_category = Category.find_or_create_by!(name: "Uncategorized Income", kind: "income")
    expense_category = Category.find_or_create_by!(name: "Uncategorized Expense", kind: "expense")
    created = 0
    errors = []

    rows = CSV.read(file.path, headers: true)
    headers = rows.headers&.compact&.map { |header| header.to_s.strip.downcase } || []
    expected_headers = %w[date description debit credit]
    alternate_headers = %w[date id amount description]
    use_default_headers = headers.empty? || ((headers & expected_headers).empty? && (headers & alternate_headers).empty?)

    if use_default_headers
      raw_rows = CSV.read(file.path, headers: false)
      header_set = raw_rows.first&.length == 3 ? %w[date debit credit] : expected_headers
      rows = CSV.read(file.path, headers: header_set)
      row_number_offset = 1
    else
      row_number_offset = 2
    end

    rows.each_with_index do |row, index|
      normalized = row.to_h.transform_keys { |key| key.to_s.strip.downcase }
      date_raw = normalized["date"]
      description = normalized["description"].to_s.strip
      import_id = normalized["id"].to_s.strip
      amount_raw = normalized["amount"].to_s.strip
      debit_raw = normalized["debit"].to_s.strip
      credit_raw = normalized["credit"].to_s.strip

      row_number = index + row_number_offset

      if date_raw.to_s.strip.empty?
        errors << "Row #{row_number}: missing date."
        next
      end

      occurred_on = parse_date(date_raw)
      unless occurred_on
        errors << "Row #{row_number}: invalid date '#{date_raw}'."
        next
      end

      amount = amount_raw.empty? ? amount_from_columns(debit_raw, credit_raw) : parse_amount(amount_raw)
      if amount.nil?
        errors << "Row #{row_number}: missing amount."
        next
      end

      category = amount.positive? ? income_category : expense_category
      description = "Imported transaction" if description.empty?

      transaction = Transaction.new(
        account: account,
        category: category,
        occurred_on: occurred_on,
        amount: amount,
        description: description,
        notes: import_id.empty? ? nil : "Import ID: #{import_id}"
      )

      if transaction.save
        created += 1
      else
        errors << "Row #{row_number}: #{transaction.errors.full_messages.to_sentence}."
      end
    end

    { created: created, errors: errors }
  end

  def amount_from_columns(debit_raw, credit_raw)
    debit = parse_amount(debit_raw)
    credit = parse_amount(credit_raw)
    debit = debit&.abs
    credit = credit&.abs

    return credit - debit if debit && credit
    return -debit if debit
    return credit if credit

    nil
  end

  def parse_amount(value)
    cleaned = value.to_s.strip
    return nil if cleaned.empty?

    negative = cleaned.start_with?("(") && cleaned.end_with?(")")
    cleaned = cleaned.tr("(),", "")
    cleaned = cleaned.gsub(/[^\d.\-]/, "")
    number = BigDecimal(cleaned)
    negative ? -number : number
  rescue ArgumentError
    nil
  end

  def assign_associations(transaction)
    account_id = params.dig(:transaction, :account_id)
    category_id = params.dig(:transaction, :category_id)

    transaction.account = Account.find_by(id: account_id) if account_id.present?
    transaction.category = Category.find_by(id: category_id) if category_id.present?
  end

  def parse_date(value)
    raw = value.to_s.strip
    return nil if raw.empty?

    formats = [
      "%m/%d/%Y",
      "%m/%d/%y",
      "%Y-%m-%d",
      "%m-%d-%Y",
      "%m-%d-%y"
    ]

    formats.each do |format|
      begin
        return Date.strptime(raw, format)
      rescue ArgumentError
        next
      end
    end

    begin
      Date.parse(raw)
    rescue ArgumentError
      nil
    end
  end
end
