class Account < ApplicationRecord
  TYPES = %w[checking savings credit cash investment].freeze
  PAYMENT_FREQUENCIES = %w[weekly biweekly semimonthly monthly quarterly yearly].freeze

  has_many :transactions, dependent: :destroy
  has_many :recurring_incomes, dependent: :destroy
  has_many :recurring_bills, dependent: :destroy

  validates :name, :currency, presence: true
  validates :opening_balance, numericality: true
  validates :account_type, inclusion: { in: TYPES }, allow_blank: true
  validates :credit_limit, :minimum_payment, :payment_amount, :original_principal, :remaining_principal,
            numericality: true, allow_nil: true
  validates :interest_rate, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :statement_day, :due_day,
            numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 31 },
            allow_nil: true
  validates :term_months, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :payment_frequency, inclusion: { in: PAYMENT_FREQUENCIES }, allow_nil: true
end
