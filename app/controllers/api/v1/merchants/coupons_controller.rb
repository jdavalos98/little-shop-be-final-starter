class Api::V1::Merchants::CouponsController < ApplicationController
  rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity_response
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found_response
  
  def index
    merchant = Merchant.find(params[:merchant_id])
    coupons = if params[:status].present?
                merchant.coupons.where(active: params[:status] == 'active')
              else
                merchant.coupons
              end
  
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
    coupon = Coupon.find(params[:id])
  
    if params[:coupon]&.key?(:active)
      new_status = ActiveModel::Type::Boolean.new.cast(params[:coupon][:active])
      
      if coupon.change_activation_status(new_status)
        render json: CouponSerializer.new(coupon), status: :ok
      else
        render json: { error: coupon.errors.full_messages.to_sentence }, status: :unprocessable_entity
      end
    else
      render json: { error: "Active status not provided" }, status: :bad_request
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
