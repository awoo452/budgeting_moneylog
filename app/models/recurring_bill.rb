class RecurringBill < ApplicationRecord
  CADENCES = %w[weekly biweekly semimonthly monthly quarterly yearly one_time].freeze

  belongs_to :account
  belongs_to :category
  belongs_to :transfer_account, class_name: "Account", optional: true

  validates :name, :amount, :cadence, :next_due_on, presence: true
  validates :amount, numericality: true
  validates :cadence, inclusion: { in: CADENCES }
  validates :due_day, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 31 }, allow_nil: true

  validate :category_is_bill_kind
  validate :transfer_account_required_for_transfer_category
  validate :transfer_account_not_same_as_pay_from

  scope :active, -> { where(active: true) }

  def next_due_on_after(date = next_due_on)
    return date if date.nil?

    case cadence
    when "weekly"
      date + 7.days
    when "biweekly"
      date + 14.days
    when "semimonthly"
      semimonthly_next_date(date)
    when "monthly"
      date.next_month
    when "quarterly"
      date.next_month(3)
    when "yearly"
      date.next_year
    when "one_time"
      date
    else
      date
    end
  end

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

  def semimonthly_next_date(date)
    if date.day < 15
      Date.new(date.year, date.month, 15)
    else
      date.beginning_of_month.next_month
    end
  end
end
