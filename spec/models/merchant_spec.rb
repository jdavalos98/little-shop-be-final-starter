require 'rails_helper'

RSpec.describe Merchant, type: :model do
  describe "associations" do
    it { should have_many(:items).dependent(:destroy) }
    it { should have_many(:invoices).dependent(:destroy) }
    it { should have_many(:customers).through(:invoices) }
    it { should have_many(:coupons) }
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
  end

  describe "class methods" do
    describe ".sorted_by_creation" do
      it "returns merchants ordered by most recently created" do
        merchant1 = create(:merchant, created_at: 1.day.ago)
        merchant2 = create(:merchant, created_at: 2.days.ago)
        merchant3 = create(:merchant, created_at: 3.days.ago)

        expect(Merchant.sorted_by_creation).to eq([merchant1, merchant2, merchant3])
      end
    end

    describe ".filter_by_status" do
      it "returns merchants with invoices of the given status" do
        merchant1 = create(:merchant)
        merchant2 = create(:merchant)
        merchant3 = create(:merchant)
        create(:invoice, merchant: merchant1, status: "shipped")
        create(:invoice, merchant: merchant2, status: "shipped")
        create(:invoice, merchant: merchant3, status: "pending")

        expect(Merchant.filter_by_status("shipped")).to match_array([merchant1, merchant2])
        expect(Merchant.filter_by_status("pending")).to match_array([merchant3])
      end
    end

    describe ".find_all_by_name" do
      it "returns all merchants that match the given name, case insensitive" do
        merchant1 = create(:merchant, name: "The Best Shop")
        merchant2 = create(:merchant, name: "THE BEST SHOP")
        merchant3 = create(:merchant, name: "Not Matching")

        expect(Merchant.find_all_by_name("best")).to match_array([merchant1, merchant2])
      end
    end

    describe ".find_one_merchant_by_name" do
      it "returns the first merchant that matches the name, case insensitive, in alphabetical order" do
        merchant1 = create(:merchant, name: "Apple Store")
        merchant2 = create(:merchant, name: "Amazon Shop")
        merchant3 = create(:merchant, name: "Best Buy")

        expect(Merchant.find_one_merchant_by_name("store")).to eq(merchant1)
      end
    end
  end

  describe "instance methods" do
    describe "#item_count" do
      it "returns the total count of items for the merchant" do
        merchant = create(:merchant)
        create_list(:item, 3, merchant: merchant)

        expect(merchant.item_count).to eq(3)
      end
    end

    describe "#distinct_customers" do
      it "returns a collection of distinct customers for the merchant" do
        merchant = create(:merchant)
        customer1 = create(:customer)
        customer2 = create(:customer)
        create(:invoice, merchant: merchant, customer: customer1)
        create(:invoice, merchant: merchant, customer: customer2)
        create(:invoice, merchant: merchant, customer: customer1)

        expect(merchant.distinct_customers).to contain_exactly(customer1, customer2)
      end
    end

    describe "#invoices_filtered_by_status" do
      it "returns invoices for the merchant with the given status" do
        merchant = create(:merchant)
        invoice1 = create(:invoice, merchant: merchant, status: "shipped")
        invoice2 = create(:invoice, merchant: merchant, status: "pending")

        expect(merchant.invoices_filtered_by_status("shipped")).to contain_exactly(invoice1)
        expect(merchant.invoices_filtered_by_status("pending")).to contain_exactly(invoice2)
      end
    end

    describe "#coupons_count" do
      it "returns the total count of coupons for the merchant" do
        merchant = create(:merchant)
        create_list(:coupon, 3, merchant: merchant)

        expect(merchant.coupons_count).to eq(3)
      end
    end

    describe "#invoice_coupon_count" do
      it "returns the count of invoices with a coupon applied for the merchant" do
        merchant = create(:merchant)
        coupon = create(:coupon, merchant: merchant)
        create(:invoice, merchant: merchant, coupon: coupon)
        create(:invoice, merchant: merchant, coupon: coupon)
        create(:invoice, merchant: merchant, coupon: nil)

        expect(merchant.invoice_coupon_count).to eq(2)
      end
    end
  end
end