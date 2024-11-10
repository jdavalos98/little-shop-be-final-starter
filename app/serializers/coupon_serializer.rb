class CouponSerializer
  include JSONAPI::ErrorSerializer
  attributes :name, :code, :discount_type, :discount_value, :active

  attribute :usage_count do |coupon|
    coupon.invoices.count
  end
end