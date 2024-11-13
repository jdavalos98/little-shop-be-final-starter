require 'rails_helper'

RSpec.describe "Mercahnts endpoints" type: :request do
  let!(:merchants) { create_list(:merchant, 3) }

  describe "GET #index" do
    it "returns a successful response" do
      get "/api/v1/merchants"
      expect(response).to have_http_status(:ok)

      data = JSON.parse(response.body)["data"]
      expect(data.size).to eq(3)
      expect(data.first["attributes"]).to include("coupons_count", "invoice_coupon_count")
    end
  end

  describe "GET #show" do
    it "returns the merchant when given a valid ID" do
      merchant = merchants.first
      get "/api/v1/merchants/#{merchant.id}"
      expect(response).to have_http_status(:ok)

      data = JSON.parse(response.body)["data"]
      expect(data["id"]).to eq(merchant.id.to_s)
      expect(data["attributes"]["name"]).to eq(merchant.name)
    end

    it "returns a 404 error when the merchant ID does not exist" do
      get "/api/v1/merchants/999999"
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST #create" do
    context "with valid parameters" do
      it "creates a new merchant and returns a successful response" do
        valid_params = { name: "New Merchant" }
        expect {
          post "/api/v1/merchants", params: valid_params
        }.to change(Merchant, :count).by(1)

        expect(response).to have_http_status(:created)
        data = JSON.parse(response.body)["data"]
        expect(data["attributes"]["name"]).to eq("New Merchant")
      end
    end

    context "with invalid parameters" do
      it "returns an error when required parameters are missing" do
        invalid_params = { name: "" }
        post "/api/v1/merchants", params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)

        error = JSON.parse(response.body)["errors"].first
        expect(error).to include("can't be blank")
      end
    end
  end

  describe "PATCH #update" do
    let(:merchant) { merchants.first }

    context "with valid parameters" do
      it "updates the merchant and returns a successful response" do
        updated_params = { name: "Updated Merchant Name" }
        patch "/api/v1/merchants/#{merchant.id}", params: updated_params

        expect(response).to have_http_status(:ok)
        data = JSON.parse(response.body)["data"]
        expect(data["attributes"]["name"]).to eq("Updated Merchant Name")
        expect(merchant.reload.name).to eq("Updated Merchant Name")
      end
    end

    context "with invalid parameters" do
      it "returns an error when the update fails" do
        invalid_params = { name: "" }
        patch "/api/v1/merchants/#{merchant.id}", params: invalid_params

        expect(response).to have_http_status(:unprocessable_entity)
        error = JSON.parse(response.body)["errors"].first
        expect(error).to include("can't be blank")
      end
    end
  end

  describe "DELETE #destroy" do
    it "deletes the merchant and returns a successful response" do
      merchant = merchants.first
      expect {
        delete "/api/v1/merchants/#{merchant.id}"
      }.to change(Merchant, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end

    it "returns a 404 error when trying to delete a non-existent merchant" do
      delete "/api/v1/merchants/999999"
      expect(response).to have_http_status(:not_found)
    end
  end
end