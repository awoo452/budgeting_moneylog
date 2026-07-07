# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.10] - 2026-07-06
### Fixed
- CI's Brakeman check failed with "not the latest version" (`bin/brakeman` passes `--ensure-latest`) — not a security finding, just an outdated gem. Updated `brakeman` from 8.0.4 to 8.0.5.

## [0.0.9] - 2026-07-06
### Added
- "Build Your Budget" (`/budgets/build`): a single screen listing every expense category with its recent average spend, anything already scheduled to bill against it this month, and an editable amount box — save all of them in one submission instead of creating budgets one at a time. Replaces the old blind "Generate Budgets" button (which silently overwrote existing budgets with no preview) and the read-only suggestions table.
### Fixed
- Budgets entered for any day other than the 1st of the month silently never appeared on the budgets page — the form allowed any date, but the index page matched on the exact 1st-of-month value. `Budget#month` is now always normalized to the beginning of the month before saving.
- Nothing stopped creating two budgets for the same category and month, which silently double-counted every total (Budgeted/Remaining/Projected) on the budgets page. Added a uniqueness validation plus a DB unique index on `(category_id, month)`.
- The budget form let you pick income or transfer categories, but the actual-spend comparison only ever looks at expense transactions, so those budgets always showed $0 actual/full remaining. Budgets are now restricted to expense categories, and the picker only lists them.
- Budget amounts could be zero or negative. Now must be greater than 0.
- **Recurring bills/income with a cadence shorter than a month (weekly, biweekly, semimonthly) were only counted once per month on both the Budgets page and Dashboard**, instead of for every actual occurrence — e.g. a $10/week subscription showed as "$10 expected" instead of ~$50. Extracted the cadence-stepping logic (previously only on `RecurringBill`, and dead code beyond payment application) into a shared `RecurringSchedule` concern with `occurrences_between(start_date, end_date)`, used by both `RecurringBill` and `RecurringIncome`. This also fixes bills/income whose `next_due_on` had drifted into a past month (e.g. a forgotten payment) — they now correctly catch up to the current period instead of silently disappearing from every future forecast.
- The "suggested budget" average always divided actual spend by a flat 3 months, even if you only had one month of transaction history — badly understating the suggestion for anyone who hadn't been tracking long. Now divides by however many of the last 3 months actually have data for that category.

## [0.0.8] - 2026-03-30
### Changed
- Updated thruster to 0.1.20.

## [0.0.7] - 2026-03-30
### Changed
- Updated Rails to 8.1.3 and action_text-trix to 2.1.18 to address security advisories.

## [0.0.6] - 2026-03-30
### Changed
- Updated mcp to 0.10.0 to address CVE-2026-33946.

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
