class RecurringBill < ApplicationRecord
  include RecurringSchedule

  belongs_to :account
  belongs_to :category
  belongs_to :transfer_account, class_name: "Account", optional: true

  validates :name, :amount, :cadence, :next_due_on, presence: true
  validates :amount, numericality: true
  validates :due_day, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 31 }, allow_nil: true

  validate :category_is_bill_kind
  validate :transfer_account_required_for_transfer_category
  validate :transfer_account_not_same_as_pay_from

  private

  def category_is_bill_kind
    return if category&.kind.in?(%w[expense transfer])

    errors.add(:category, "must be an expense or transfer category")
  end

  def transfer_account_required_for_transfer_category
    return unless category&.kind == "transfer"

    errors.add(:transfer_account, "must be set for transfer bills") if transfer_account.nil?
  end

  def transfer_account_not_same_as_pay_from
    return if transfer_account_id.blank? || account_id.blank?
    return if transfer_account_id != account_id

    errors.add(:transfer_account, "must be different from the pay-from account")
  end
end
