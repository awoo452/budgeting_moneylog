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
