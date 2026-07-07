module RecurringOccurrences
  extend ActiveSupport::Concern

  private

  # Expands each active recurring bill/income into one entry per actual
  # occurrence within [start_date, end_date], instead of only counting
  # whichever single next_due_on happens to fall in range.
  def occurrences_for(scope, start_date, end_date)
    scope.flat_map do |record|
      record.occurrences_between(start_date, end_date).map do |date|
        { record: record, date: date, amount: record.amount }
      end
    end.sort_by { |occurrence| occurrence[:date] }
  end
end
