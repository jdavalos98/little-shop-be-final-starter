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
    if new_status
      if merchant.coupons.where(active: true).count >= 5
        errors.add(:base, "Merchant cannot have more than 5 active coupons")
        return false
      else
        update!(active: true)
      end
    else
      if has_pending_invoices?
        errors.add(:base, "Coupon cannot be deactivated because it has pending invoices")
        return false
      else
        update!(active: false)
      end
    end
  end

  def has_pending_invoices?
    Invoice.where(coupon_id: id, status: "pending").exists?
  end

  def usage_count
    Invoice.where(coupon_id: id).count
  end
end