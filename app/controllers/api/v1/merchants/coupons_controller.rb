class Api::V1::Merchants::CouponsController < ApplicationController

  def index 
    merchant = Merchant.find(params[:merchant_id])
    coupons = merchant.coupons

    render json: CouponSerializer.new(coupons), status: :ok
  end
  def show 
    merchant = Merchant.find(params[:merchant_id])
    coupon = merchant.coupons.find(params[:id])

    render json: CouponSerializer.new(coupon)
  end
end
