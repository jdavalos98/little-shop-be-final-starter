require 'rails_helper'

RSpec.describe "Invoice endpoints", type: :request do
  let!(:merchant) { create(:merchant) }
  let!(:customer) { create(:customer) }
  let!(:invoices) { create_list(:invoice, 5, merchant: merchant, customer: customer) }
  let!(:pending_invoice) { create(:invoice, merchant: merchant, customer: customer, status: "pending") }
  let!(:shipped_invoice) { create(:invoice, merchant: merchant, customer: customer, status: "shipped") }

  describe "GET #index" do
    describe "without status filter" do
      it "returns all invoices for the specified merchant" do
        get "/api/v1/merchants/#{merchant.id}/invoices"

        json = JSON.parse(response.body, symbolize_names: true)
        expect(response).to have_http_status(:ok)
        expect(json[:data].size).to eq(7)
        expect(json[:data].first).to include(:id, :type, :attributes)
        expect(json[:data].first[:attributes]).to include(:status, :customer_id, :merchant_id)
      end
    end

    describe "with status filter" do
      it "returns only invoices with the specified status" do
        get "/api/v1/merchants/#{merchant.id}/invoices?status=pending"

        json = JSON.parse(response.body, symbolize_names: true)
        expect(response).to have_http_status(:ok)
        expect(json[:data].size).to eq(1)
        expect(json[:data].first[:attributes][:status]).to eq("pending")
      end

      it "returns multiple invoices if more than one match the status" do
        # Changing existing invoices to "shipped" for this test
        create_list(:invoice, 3, merchant: merchant, customer: customer, status: "shipped")

        get "/api/v1/merchants/#{merchant.id}/invoices?status=shipped"

        json = JSON.parse(response.body, symbolize_names: true)
        expect(response).to have_http_status(:ok)
        expect(json[:data].size).to eq(4) # 1 existing + 3 newly created with "shipped" status
        expect(json[:data].all? { |invoice| invoice[:attributes][:status] == "shipped" }).to be true
      end
    end

    describe "sad paths" do
      it "returns a 404 error if the merchant ID is invalid" do
        get "/api/v1/merchants/999999/invoices"
        json = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(:not_found)
        expect(json[:errors]).to include("Couldn't find Merchant with 'id'=999999")
      end

      it "returns an empty array if no invoices match the specified status" do
        get "/api/v1/merchants/#{merchant.id}/invoices?status=non_existent_status"
        json = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(:ok)
        expect(json[:data]).to be_empty
      end
    end
  end
end