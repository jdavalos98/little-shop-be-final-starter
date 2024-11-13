require 'rails_helper'

RSpec.describe "Coupons API", type: :request do
  let!(:merchant) { create(:merchant) }
  let!(:coupon) { create(:coupon, merchant: merchant) }

  describe "GET /api/v1/merchants/:merchant_id/coupons" do
    it "returns all coupons for a merchant" do
      get "/api/v1/merchants/#{merchant.id}/coupons"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body, symbolize_names: true)
      expect(json[:data].size).to eq(1)
    end

    it "filters coupons by active status" do
      get "/api/v1/merchants/#{merchant.id}/coupons?status=active"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body, symbolize_names: true)
    end
  end

  describe "PATCH /api/v1/merchants/:merchant_id/coupons/:id" do
    context "with valid parameters" do
      it "updates the coupon status" do
        patch "/api/v1/merchants/#{merchant.id}/coupons/#{coupon.id}", params: { coupon: { active: false } }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body, symbolize_names: true)
        expect(json[:data][:attributes][:active]).to eq(false)
      end
    end

    context "without active status parameter" do
      it "returns an error" do
        patch "/api/v1/merchants/#{merchant.id}/coupons/#{coupon.id}", params: { coupon: {} }

        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body, symbolize_names: true)
        expect(json[:error]).to eq("Active status not provided")
      end
    end
  end
end