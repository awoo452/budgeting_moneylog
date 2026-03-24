class Category < ApplicationRecord
  KINDS = %w[income expense transfer].freeze

  has_many :transactions, dependent: :destroy
  has_many :budgets, dependent: :destroy
  has_many :recurring_incomes, dependent: :destroy
  has_many :recurring_bills, dependent: :destroy

  validates :name, presence: true
  validates :kind, inclusion: { in: KINDS }
end
