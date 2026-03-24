# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.5] - 2026-03-24
### Added
- Added recurring income schedules with CRUD screens and dashboard upcoming totals.
- Added recurring bill schedules with autopay and variable-amount flags.
- Added debt tracking fields on accounts (APR, due dates, minimum payments, terms).
- Added navigation links for recurring income and bills.
### Changed
- Dashboard recurring cashflow window aligns to the current calendar month.
- Budgets page now includes recurring income/bill schedules and projected remaining amounts.
- Budgets page tables now include totals rows.
- Removed inline styling from views (notices/alerts).
- Transfer-account support for recurring bills, plus an apply-payment action that records matching transactions.
- Recurring bills use transfer categories (for loan or credit payments).
### Fixed
- Recurring bill/income associations are now assigned explicitly to satisfy Brakeman.

## [0.0.4] - 2026-03-23
### Fixed
- Avoided permitting params in the transactions view (Brakeman warning).
- Fixed array literal spacing in transactions filters (RuboCop).

## [0.0.3] - 2026-03-23
### Added
- Added a statement text importer for pasted card statements.
- Added support to bypass statement import de-duplication.
- Added transaction type filtering (income vs expense) with quick links and a type column.
- Added `current_balance` to accounts for manual balance tracking.
- Added current balance display on account list and detail pages.
- Added current balance field to account create/edit form.
- Added budget planner view with month filter, actuals, and 3-month average suggestions.
- Added transfer as a category type with filtering on the transactions page.
### Changed
- Statement text import now inserts all rows by default (opt-in de-duplication).
### Fixed
- Dashboard income/expense totals now use category kind to avoid mixing income into expenses.
- Transaction type filtering now ignores mismatched categories and limits the category list by type.

## [0.0.2] - 2026-03-23
### Added
- Added basic transaction filters for account and category.
- Added sorting by amount (largest first) on the transactions page.
- Added dashboard links to jump from a category total to its transactions.
- Added a basic transaction search field on the transactions page.

## [0.0.1] - 2026-03-23
### Added
- Initial budgeting/moneylog template with CRUD for accounts, categories, transactions, and budgets.
### Added
- Seed data for baseline accounts, categories, budgets, and transactions.
### Added
- CSV import support for files with `date`, `id`, `amount`, and `description`.
### Added
- Dashboard with basic income/expense summaries and category totals.
### Fixed
- Improved CSV date parsing to accept common US formats (like `3/23/2026`).
- Avoided mass-assigning transaction associations to satisfy security scanning.
### Changed
- Bumped `solid_queue` from `1.3.2` to `1.4.0`.
- Bumped `rails` from `8.1.2` to `8.1.2.1`.
