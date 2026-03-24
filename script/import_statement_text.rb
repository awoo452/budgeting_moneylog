# frozen_string_literal: true

# Usage:
#   bin/rails runner script/import_statement_text.rb /path/to/statement.txt ACCOUNT_ID [--year=2025] [--use-post-date] [--no-invert] [--dedupe]
#
# Expects lines like:
#   08/18 08/17 2449216762X4B48HZ OPENAI *CHATGPT SUBSCR OPENAI.COM CA $22.06
#   08/18 08/18 74428687600XSX84M PAYMENT - THANK YOU -$7,500.00

require "date"
require "bigdecimal"

file_path = ARGV[0]
account_id = ARGV[1]

unless file_path && account_id
  puts "Usage: bin/rails runner script/import_statement_text.rb /path/to/statement.txt ACCOUNT_ID [--year=2025] [--use-post-date] [--no-invert] [--dedupe]"
  exit(1)
end

use_post_date = ARGV.include?("--use-post-date")
invert_amounts = !ARGV.include?("--no-invert")
dedupe = ARGV.include?("--dedupe")
year_arg = ARGV.find { |arg| arg.start_with?("--year=") }
year_override = year_arg&.split("=", 2)&.last&.to_i

account = Account.find_by(id: account_id)
unless account
  puts "Account not found for id=#{account_id}"
  exit(1)
end

income_category = Category.find_or_create_by!(name: "Uncategorized Income", kind: "income")
expense_category = Category.find_or_create_by!(name: "Uncategorized Expense", kind: "expense")

line_pattern = /\A(\d{2}\/\d{2})\s+(\d{2}\/\d{2})\s+(\S+)\s+(.+?)\s+(-?\$[\d,]+\.\d{2})\s*\z/
created = 0
skipped = 0
errors = []

File.readlines(file_path, chomp: true).each_with_index do |line, index|
  trimmed = line.strip
  next if trimmed.empty?
  next if trimmed.start_with?("Post Date")

  match = trimmed.match(line_pattern)
  unless match
    errors << "Line #{index + 1}: could not parse '#{trimmed}'"
    next
  end

  post_date, trans_date, reference, description, amount_raw = match.captures
  date_raw = use_post_date ? post_date : trans_date
  month, day = date_raw.split("/").map(&:to_i)
  year = year_override || (month > Date.current.month ? Date.current.year - 1 : Date.current.year)

  begin
    occurred_on = Date.new(year, month, day)
  rescue ArgumentError
    errors << "Line #{index + 1}: invalid date '#{date_raw}/#{year}'"
    next
  end

  amount = BigDecimal(amount_raw.tr("$,", ""))
  amount = -amount if invert_amounts
  category = amount.positive? ? income_category : expense_category

  if dedupe
    if reference && !reference.empty?
      existing = Transaction.find_by(account: account, notes: "Ref: #{reference}")
      if existing
        skipped += 1
        next
      end
    end

    transaction = Transaction.find_or_initialize_by(
      account: account,
      occurred_on: occurred_on,
      amount: amount,
      description: description
    )
    if transaction.persisted?
      skipped += 1
      next
    end
  end

  transaction ||= Transaction.new(
    account: account,
    occurred_on: occurred_on,
    amount: amount,
    description: description
  )

  transaction.category = category
  transaction.notes = "Ref: #{reference}"

  if transaction.save
    created += 1
  else
    errors << "Line #{index + 1}: #{transaction.errors.full_messages.to_sentence}"
  end
end

puts "Created: #{created}"
puts "Skipped (duplicates): #{skipped}"
if errors.any?
  puts "Errors:"
  errors.each { |error| puts "  - #{error}" }
end
