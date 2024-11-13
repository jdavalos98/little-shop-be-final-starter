class CouponSerializer
  include JSONAPI::Serializer
  attributes :name, :code, :discount_type, :discount_value, :active

  attribute :discount_value do |coupon|
    coupon.discount_value.to_f
  end

  attribute :usage_count do |coupon|
    coupon.usage_count
  end
end