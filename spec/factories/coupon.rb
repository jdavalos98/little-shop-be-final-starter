FactoryBot.define do
  factory :coupon do
    associaiton :merchant
    name {Faker::Commerce.promotion_code}
    code {Faker::Alphanumeric.unique.alpha(number: 6).upcase}
    discount_type { %w[percent dollar].sample}
    discount_value { discount_type == 'percent' ? rand(5..50) : rand(1..20)}
    active {true}
  end
end