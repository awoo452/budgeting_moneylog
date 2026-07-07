class RecurringIncome < ApplicationRecord
  include RecurringSchedule

  belongs_to :account
  belongs_to :category

  validates :name, :amount, :cadence, :next_due_on, presence: true
  validates :amount, numericality: true

  validate :category_is_income

  private

  def category_is_income
    return if category&.kind == "income"

    errors.add(:category, "must be an income category")
  end
end
