class Transaction < ApplicationRecord
  belongs_to :account
  belongs_to :category

  validates :occurred_on, :amount, :description, presence: true
  validates :amount, numericality: true
end
