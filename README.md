# Budgeting & Moneylog Template

This repo is a basic budgeting template with CRUD flows for accounts, categories, transactions, and monthly budgets. It intentionally ships without custom CSS so you can layer on your own styles.

## Features

- Accounts for banks, cash, and credit balances.
- Categories for income and expense tracking.
- Transactions with dates, amounts, accounts, and categories.
- Transaction filters for account/category, basic search, and amount sorting.
- CSV import for transactions (date, description, debit, credit) with account selection.
- Budgets for monthly category targets.
- Dashboard with basic income/expense summaries and category totals (click a category to see its transactions).
- Recurring income and bill schedules for upcoming cashflow.
- Debt details for credit/loan accounts (APR, due dates, minimum payments).

## Core Schema

### Account
Required fields:
- `name`
- `currency`
- `opening_balance`

Optional fields:
- `institution`
- `account_type`
- `opened_on`
- `current_balance`
- `credit_limit`
- `interest_rate`
- `statement_day`
- `due_day`
- `next_payment_due_on`
- `minimum_payment`
- `payment_amount`
- `payment_frequency`
- `original_principal`
- `remaining_principal`
- `term_months`
- `promo_apr_end`
- `autopay`
- `notes`

### Category
Required fields:
- `name`
- `kind` (`income` or `expense`)

Optional fields:
- `archived`
- `notes`

### Transaction
Required fields:
- `account_id`
- `category_id`
- `occurred_on`
- `amount`
- `description`

Optional fields:
- `payment_method`
- `notes`

### Budget
Required fields:
- `category_id`
- `month`
- `amount`

Optional fields:
- `notes`

### Recurring income
Required fields:
- `name`
- `amount`
- `cadence`
- `next_due_on`
- `account_id`
- `category_id`

Optional fields:
- `active`
- `notes`

### Recurring bill
Required fields:
- `name`
- `amount`
- `cadence`
- `next_due_on`
- `account_id`
- `category_id`

Optional fields:
- `due_day`
- `last_paid_on`
- `autopay`
- `variable_amount`
- `transfer_account_id`
- `active`
- `notes`

Notes:
- Recurring bills can use expense or transfer categories (for loan or card payments).
- Applying a recurring bill creates a transaction and, if `transfer_account_id` is set, applies a matching transfer to the related account.

## CSV Import

Upload a CSV from `Transactions -> Import CSV`. Files may include headers for `date`, `description`, `debit`, and `credit` or the alternate format `date`, `id`, `amount`, and `description`. If headers are missing, the importer assumes column order of `date`, `description` (optional), `debit`, and `credit`. Debit amounts import as negatives, credits as positives. Transactions are categorized as `Uncategorized Income` or `Uncategorized Expense` based on the sign.

## Statement Text Import

If you only have a copied statement (no CSV), paste it into a text file and run the importer:

```bash
bin/rails runner script/import_statement_text.rb /path/to/statement.txt ACCOUNT_ID
```

Options:
- `--year=2025` to override the year (default uses the most recent reasonable year).
- `--use-post-date` to use the first date column instead of the transaction date.
- `--no-invert` if your amounts already use negative for expenses.
- `--dedupe` to skip statement rows that already exist (based on reference when available).

## Transactions Search

The transactions index supports basic search across `description`, `notes`, and `payment_method`, alongside account/category filters and amount sorting.

## Setup

Prereqs: Ruby and PostgreSQL.

1. `bundle install`
2. `bin/rails db:create db:migrate`

## Run

1. `bin/rails server`
2. Open `http://localhost:3000`

## Tests

1. `bin/rails test`

## Changelog

See [`CHANGELOG.md`](CHANGELOG.md) for notable changes.
