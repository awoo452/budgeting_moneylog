class Category < ApplicationRecord
  KINDS = %w[income expense].freeze

  has_many :transactions, dependent: :destroy
  has_many :budgets, dependent: :destroy

  validates :name, presence: true
  validates :kind, inclusion: { in: KINDS }
end
