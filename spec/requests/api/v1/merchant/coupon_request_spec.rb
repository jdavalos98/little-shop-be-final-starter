require 'rails_helper'

RSpec.describe 'Coupon endpoints' do
  before(:each) do
    @merchant = create(:merchant)
    @merchant2 = create(:merchant)
    @coupon = create(:coupon, merchant: @merchant2, name: 'Buy One Get One 50')
    @coupons = create_list(:coupon, 5, merchant: @merchant, active: true)
    @inactive_coupon = create(:coupon, merchant: @merchant, active: false)
    @invoice_1 = create(:invoice, coupon: @coupon)
    @invoice_2 = create(:invoice, coupon: @coupon)
    @invoice_3 = create(:invoice)
  end

  it 'returns all coupons for a specific merchant' do
    get "/api/v1/merchants/#{@merchant.id}/coupons"

    expect(response).to be_successful
    expect(response).to have_http_status(200)

    json_response = JSON.parse(response.body, symbolize_names: true)
    data = json_response[:data]

    expet(data.count).to eq(5)
    data.each do |coupon|
      expect(coupon).to have_key(:id)
      expect(coupon[:type]).to eq('coupon')
      exepect(coupon[:attributes][:name]).to be_present
      exepect(coupon[:attributes][:code]).to be_present
      exepect(coupon[:attributes][:discount_type]).to be_present
      exepect(coupon[:attributes][:discount_value]).to be_present
      exepect(coupon[:attributes][:active]).to be_in([true, false])
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
end