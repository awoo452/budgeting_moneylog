# Budgeting & Moneylog Template

This repo is a basic budgeting template with CRUD flows for accounts, categories, transactions, and monthly budgets. It intentionally ships without custom CSS so you can layer on your own styles.

## Features

- Accounts for banks, cash, and credit balances.
- Categories for income and expense tracking.
- Transactions with dates, amounts, accounts, and categories.
- CSV import for transactions (date, description, debit, credit) with account selection.
- Budgets for monthly category targets.
- Dashboard with basic income/expense summaries and category totals.

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
