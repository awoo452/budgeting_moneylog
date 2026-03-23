class Account < ApplicationRecord
  TYPES = %w[checking savings credit cash investment].freeze

  has_many :transactions, dependent: :destroy

  validates :name, :currency, presence: true
  validates :opening_balance, numericality: true
  validates :account_type, inclusion: { in: TYPES }, allow_blank: true
end
