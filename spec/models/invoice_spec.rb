# spec/models/invoice_spec.rb
require 'rails_helper'

RSpec.describe Invoice, type: :model do
  let(:merchant) { create(:merchant) }
  let(:customer) { create(:customer) }

  describe "associations" do
    it { should belong_to(:merchant) }
    it { should belong_to(:customer) }
    it { should belong_to(:coupon).optional }
    it { should have_many(:invoice_items).dependent(:destroy) }
    it { should have_many(:transactions).dependent(:destroy) }
  end

  describe "validations" do
    describe "when status is blank or nil" do
      it "is invalid without a status" do
        invoice = build(:invoice, status: nil, merchant: merchant, customer: customer)
        expect(invoice).not_to be_valid
        expect(invoice.errors[:status]).to include("can't be blank")
      end
    end

    describe "when status is an invalid value" do
      it "is invalid with a status not in the allowed list" do
        invoice = build(:invoice, status: "invalid_status", merchant: merchant, customer: customer)
        expect(invoice).not_to be_valid
        expect(invoice.errors[:status]).to include("is not included in the list")
      end
    end

    describe "when status is valid" do
      it "is valid with a status of shipped, packaged, returned, pending, or completed" do
        %w[shipped packaged returned pending completed].each do |valid_status|
          invoice = build(:invoice, status: valid_status, merchant: merchant, customer: customer)
          expect(invoice).to be_valid, "expected #{valid_status} to be a valid status"
        end
      end
    end
  end
end