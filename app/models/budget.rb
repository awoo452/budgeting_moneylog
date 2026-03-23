class Budget < ApplicationRecord
  belongs_to :category

  validates :month, :amount, presence: true
  validates :amount, numericality: true
end
