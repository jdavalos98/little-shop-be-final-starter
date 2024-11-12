class Coupon < ApplicationRecord
  belongs_to :merchant

  validates :name, presence: true
  validates :code, presence: true, uniqueness: true
  validates :discount_type, inclusion: { in: %w[percent dollar] }
  validates :discount_value, presence: true, numericality: { greater_than: 0 }
  validate :active_coupon_limit, if: :active?

  def active_coupon_limit
    return if merchant.nil?

    if merchant.coupons.where(active: true).count >= 5
      errors.add(:base, "Merchant cannot have more than 5 active coupons")
    end
  end

  def change_activation_status(new_status)
    new_status ? activate_coupon : deactivate_coupon
  end

  private

  def deactivate_coupon
    if has_pending_invoices?
      errors.add(:base, "Coupon cannot be deactivated because it has pending invoices")
      false
    else
      update!(active: false)
    end
  end

  def activate_coupon
    if merchant.coupons.where(active: true).count >= 5
      errors.add(:base, "Merchant cannot have more than 5 active coupons")
      false
    else
      update!(active: true)
    end
  end

  def has_pending_invoices?
    invoices.where(status: "pending").exists?
  end
end