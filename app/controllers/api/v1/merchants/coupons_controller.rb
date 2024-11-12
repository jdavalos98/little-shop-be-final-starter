class Api::V1::Merchants::CouponsController < ApplicationController
  rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity_response
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found_response

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

  def create
    merchant = Merchant.find(params[:merchant_id])
    coupon = merchant.coupons.new(coupon_params)
    coupon.save! 

    render json: CouponSerializer.new(coupon), status: :created
  end
  
  def update
    merchant = Merchant.find(params[:merchant_id])
    coupon = merchant.coupons.find(params[:id])
  
    if coupon.change_activation_status(coupon_params[:active])
      render json: CouponSerializer.new(coupon), status: :ok
    else
      render json: { errors: coupon.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def coupon_params
    params.require(:coupon).permit(:name, :code, :discount_type, :discount_value, :active)
  end

  def render_unprocessable_entity_response(exception)
    render json: { errors: exception.record.errors.full_messages }, status: :unprocessable_entity
  end

  def render_not_found_response
    render json: { errors: ["Record not found"] }, status: :not_found
  end
end
