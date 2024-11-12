require 'rails_helper'

RSpec.describe Coupon, type: :model do
  before(:each) do
    @merchant = create(:merchant)
    @active_coupons = create_list(:coupon, 5, merchant: @merchant, active: true) # 5 active coupons for the merchant
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:code) }
    it { should validate_uniqueness_of(:code) }
    it { should validate_inclusion_of(:discount_type).in_array(%w[percent dollar]) }
    it { should validate_presence_of(:discount_value) }
    it { should validate_numericality_of(:discount_value).is_greater_than(0) }
  end

  describe 'custom validations' do
    context 'active coupon limit' do
      it 'does not allow more than 5 active coupons per merchant' do
        # Attempt to create a 6th active coupon
        new_coupon = build(:coupon, merchant: @merchant, active: true)
        expect(new_coupon).not_to be_valid
        expect(new_coupon.errors[:base]).to include("Merchant cannot have more than 5 active coupons")
      end

      it 'allows creation of additional inactive coupons beyond the limit' do
        # Create an inactive coupon
        inactive_coupon = build(:coupon, merchant: @merchant, active: false)
        expect(inactive_coupon).to be_valid
      end
    end
  end
end