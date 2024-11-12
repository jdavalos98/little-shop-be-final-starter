require 'rails_helper'

RSpec.describe 'Coupon endpoints' do
  before(:each) do
    @merchant = create(:merchant)
    @merchant2 = create(:merchant)
    @coupon = create(:coupon, merchant: @merchant2, name: 'Buy One Get One 50')
    @coupons = create_list(:coupon, 5, merchant: @merchant, active: true)
    @inactive_coupon = create(:coupon, merchant: @merchant, active: false)
    @invoice_1 = create(:invoice, coupon: @coupon, status: "completed")
    @invoice_2 = create(:invoice, coupon: @coupon, status: "pending")
    @invoice_3 = create(:invoice)
  end

  it 'returns all coupons for a specific merchant' do
    get "/api/v1/merchants/#{@merchant.id}/coupons"

    expect(response).to be_successful
    expect(response).to have_http_status(200)

    json_response = JSON.parse(response.body, symbolize_names: true)
    data = json_response[:data]

    expect(data.count).to eq(6)
    data.each do |coupon|
      expect(coupon).to have_key(:id)
      expect(coupon[:type]).to eq('coupon')
      expect(coupon[:attributes][:name]).to be_present
      expect(coupon[:attributes][:code]).to be_present
      expect(coupon[:attributes][:discount_type]).to be_present
      expect(coupon[:attributes][:discount_value]).to be_present
      expect(coupon[:attributes][:active]).to be_in([true, false])
    end
  end

  it 'returns a specific coupon with usage count' do
    get "/api/v1/merchants/#{@merchant2.id}/coupons/#{@coupon.id}"

    expect(response).to be_successful  
    expect(response).to have_http_status(200)

    json_response = JSON.parse(response.body, symbolize_names: true)
    data = json_response[:data]

    expect(data).to have_key(:id)
    expect(data[:id]).to eq(@coupon.id.to_s)

    expect(data).to have_key(:type)
    expect(data[:type]).to eq('coupon')

    expect(data[:attributes]).to be_a(Hash)
    attributes = data[:attributes]  

    expect(attributes[:name]).to eq('Buy One Get One 50')
    expect(attributes[:code]).to eq(@coupon.code)
    expect(attributes[:discount_type]).to eq(@coupon.discount_type)
    expect(attributes[:discount_value]).to eq(@coupon.discount_value)
    expect(attributes[:active]).to eq(@coupon.active)
    expect(attributes[:usage_count]).to eq(2)
  end

  it 'can create a new coupon' do 
    coupon_params = {
      coupon: {
        name: "Buy One Get One 50",
        code: "BOGO50",
        discount_type: "percent",
        discount_value: 50,
        active: true
      }
    }

    post "/api/v1/merchants/#{@merchant2.id}/coupons", params: coupon_params

    expect(response).to be_successful
    expect(response).to have_http_status(:created)

    json_response = JSON.parse(response.body, symbolize_names: true)
    data = json_response[:data]

    expect(data[:attributes][:name]).to eq("Buy One Get One 50")
    expect(data[:attributes][:code]).to eq("BOGO50")
    expect(data[:attributes][:discount_type]).to eq("percent")
    expect(data[:attributes][:discount_value].to_f).to eq(50.0)
    expect(data[:attributes][:active]).to be(true)
  end

  it 'returns an error if merchant has 5 active coupons' do 
    coupon_params = {
      coupon: {
        name: "Extra Coupon",
        code: "EXTRA1",
        discount_type: "dollar",
        discount_value: 10,
        active: true
      }
    }
    
    post "/api/v1/merchants/#{@merchant.id}/coupons", params: coupon_params

    expect(response).not_to be_successful
    json_response = JSON.parse(response.body, symbolize_names: true)
    expect(json_response[:errors]).to include("Merchant cannot have more than 5 active coupons")
  end

  xit 'returns an error if coupon code is not unique' do 
    coupon_params = {
      coupon: {
        name: "Black Friday Coupon",
        code: "BOGO50",
        discount_type: "percent",
        discount_value: 50,
        active: true
      }
    }

    post "/api/v1/merchants/#{@merchant2.id}/coupons", params: coupon_params
    
    expect(response).to have_http_status(:unprocessable_entity)
    json_response = JSON.parse(response.body, symbolize_names: true)
    expect(json_response[:errors]).to include("Code has already been taken")
  end

  it 'returns a 404 not found error if merchant does not exist' do
    coupon_params = {
      coupon: {
        name: "Non-existent Merchant Coupon",
        code: "NONEXISTENT",
        discount_type: "percent",
        discount_value: 10,
        active: true
      }
    }

    post "/api/v1/merchants/99999/coupons", params: coupon_params 

    expect(response).not_to be_successful
    expect(response).to have_http_status(:not_found)
    json_response = JSON.parse(response.body, symbolize_names: true)
    expect(json_response[:errors]).to include("Record not found")
  end

  it 'deactivates an active coupon' do
    @coupon.invoices.update_all(status: "completed")
  
    patch "/api/v1/merchants/#{@merchant2.id}/coupons/#{@coupon.id}", params: {coupon: {active: false }}

    expect(response).to be_successful
    expect(response).to have_http_status(:ok)

    json_response = JSON.parse(response.body, symbolize_names: true)
    data = json_response[:data]

    expect(data[:id]).to eq(@coupon.id.to_s)
    expect(data[:attributes][:active]).to eq(false)
  end

  xit 'returns error if coupon has pending invoices' do
    patch "/api/v1/merchants/#{@merchant2.id}/coupons/#{@coupon.id}", params: {coupon: {active: false}}

    expect(response).to have_http_status(:unprocessable_entity)
    json_response = JSON.parse(response.body, symbolize_names: true)
    expect(json_response[:errors]).to incldue("Coupon cannot be deactivated because it has pending invoices")
  end
end