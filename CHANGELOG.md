# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
