require 'rails_helper'

RSpec.describe Coupon, type: :model do
  let(:merchant) { create(:merchant) }

  describe "associations" do
    it { should belong_to(:merchant) }
  end

  describe "validations" do
    subject { build(:coupon, merchant: merchant) }

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:code) }
    it { should validate_uniqueness_of(:code) }
    it { should validate_inclusion_of(:discount_type).in_array(%w[percent dollar]) }
    it { should validate_presence_of(:discount_value) }
    it { should validate_numericality_of(:discount_value).is_greater_than(0) }

    describe "when validating active_coupon_limit" do
      it "does not allow more than 5 active coupons for a merchant" do
        5.times { create(:coupon, merchant: merchant, active: true) }
        new_coupon = build(:coupon, merchant: merchant, active: true)

        expect(new_coupon).not_to be_valid
        expect(new_coupon.errors[:base]).to include("Merchant cannot have more than 5 active coupons")
      end
    end
  end

  describe "#change_activation_status" do
    let!(:coupon) { create(:coupon, merchant: merchant, active: false) }

    describe "when activating a coupon" do
      it "activates successfully if active limit is not reached" do
        expect(coupon.change_activation_status(true)).to be true
        expect(coupon.reload.active).to be true
      end

      it "does not activate if active limit is reached" do
        5.times { create(:coupon, merchant: merchant, active: true) }
        expect(coupon.change_activation_status(true)).to be false
        expect(coupon.errors[:base]).to include("Merchant cannot have more than 5 active coupons")
      end
    end

    describe "when deactivating a coupon" do
      before { coupon.update!(active: true) }

      it "deactivates successfully if there are no pending invoices" do
        allow(coupon).to receive(:has_pending_invoices?).and_return(false)
        expect(coupon.change_activation_status(false)).to be true
        expect(coupon.reload.active).to be false
      end

      it "does not deactivate if there are pending invoices" do
        allow(coupon).to receive(:has_pending_invoices?).and_return(true)
        expect(coupon.change_activation_status(false)).to be false
        expect(coupon.errors[:base]).to include("Coupon cannot be deactivated because it has pending invoices")
      end
    end
  end

  describe "#has_pending_invoices?" do
    let(:coupon) { create(:coupon, merchant: merchant) }

    it "returns true if there are pending invoices with the coupon" do
      create(:invoice, coupon: coupon, status: "pending")
      expect(coupon.has_pending_invoices?).to be true
    end

    it "returns false if there are no pending invoices with the coupon" do
      create(:invoice, coupon: coupon, status: "shipped")
      expect(coupon.has_pending_invoices?).to be false
    end
  end

  describe "#usage_count" do
    let(:coupon) { create(:coupon, merchant: merchant) }

    it "returns the correct count of invoices using the coupon" do
      create_list(:invoice, 3, coupon: coupon)
      expect(coupon.usage_count).to eq(3)
    end

    it "returns zero if no invoices are using the coupon" do
      expect(coupon.usage_count).to eq(0)
    end
  end
end