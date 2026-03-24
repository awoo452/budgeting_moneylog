class RecurringIncome < ApplicationRecord
  CADENCES = %w[weekly biweekly semimonthly monthly quarterly yearly one_time].freeze

  belongs_to :account
  belongs_to :category

  validates :name, :amount, :cadence, :next_due_on, presence: true
  validates :amount, numericality: true
  validates :cadence, inclusion: { in: CADENCES }

  validate :category_is_income

  scope :active, -> { where(active: true) }

  private

  def category_is_income
    return if category&.kind == "income"

    errors.add(:category, "must be an income category")
  end
end
