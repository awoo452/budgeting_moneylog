module RecurringSchedule
  extend ActiveSupport::Concern

  CADENCES = %w[weekly biweekly semimonthly monthly quarterly yearly one_time].freeze
  MAX_OCCURRENCES = 366

  included do
    validates :cadence, inclusion: { in: CADENCES }
    scope :active, -> { where(active: true) }
  end

  def next_due_on_after(date = next_due_on)
    return date if date.nil?

    case cadence
    when "weekly"      then date + 7.days
    when "biweekly"    then date + 14.days
    when "semimonthly" then semimonthly_next_date(date)
    when "monthly"     then date.next_month
    when "quarterly"   then date.next_month(3)
    when "yearly"      then date.next_year
    else date
    end
  end

  # Every actual occurrence date within [start_date, end_date], catching up from
  # next_due_on even if it has drifted into a past period (e.g. an unpaid bill).
  def occurrences_between(start_date, end_date)
    return [] if next_due_on.nil? || start_date.nil? || end_date.nil?
    return [] if next_due_on > end_date

    dates = []
    date  = next_due_on

    MAX_OCCURRENCES.times do
      break if date > end_date

      dates << date if date >= start_date
      break if cadence == "one_time"

      date = next_due_on_after(date)
    end

    dates
  end

  private

  def semimonthly_next_date(date)
    if date.day < 15
      Date.new(date.year, date.month, 15)
    else
      date.beginning_of_month.next_month
    end
  end
end
