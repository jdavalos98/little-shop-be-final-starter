class Coupon < ApplicationRecord
  belongs_to :merchant
  has_many :invoices

  validates :name, presence: true
  validates :code, presence: true, uniqueness: true
  validates :discount_type, inclusion: { in: %w[percent dollar] }
  validates :discount_value, presence: true, numericality: { greater_than: 0 }
  validate :active_coupon_limit, if: :active?

  def active_coupon_limit
    return if merchant.nil?

    if merchant.coupons.where(active: true).count >=5
      errors.add(:base, "Merchant cannot have more than 5 active coupons")
    end
  end
end