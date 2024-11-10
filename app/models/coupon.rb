class Coupon < ApplicationRecord
  belongs_to :merchants
  has_many :invoices 
end