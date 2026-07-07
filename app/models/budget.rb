class Budget < ApplicationRecord
  belongs_to :category

  before_validation :normalize_month_to_beginning_of_month

  validates :month, :amount, presence: true
  validates :amount, numericality: { greater_than: 0 }
  validates :category_id, uniqueness: { scope: :month }

  validate :category_must_be_expense

  private

  def normalize_month_to_beginning_of_month
    self.month = month.beginning_of_month if month.present?
  end

  def category_must_be_expense
    return if category.nil? || category.kind == "expense"

    errors.add(:category, "must be an expense category")
  end
end
