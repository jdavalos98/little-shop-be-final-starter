class Api::V1::Merchants::CouponsController < ApplicationController

  def show 
    merchant = Merchant.find(params[:merchant_id])
    coupon = merchant.coupons.find(params[:id])

    render json: CouponSerializer.new(coupon)
  end
end
