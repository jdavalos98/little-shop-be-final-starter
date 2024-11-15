class Invoice < ApplicationRecord
  belongs_to :customer
  belongs_to :merchant
  has_many :invoice_items, dependent: :destroy
  has_many :transactions, dependent: :destroy
  belongs_to :coupon, optional: true

  validates :status, presence: true, inclusion: {in: ["shipped", "packaged", "returned", "pending", "completed"]}
end