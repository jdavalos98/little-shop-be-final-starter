class CreateCoupons < ActiveRecord::Migration[6.1]
  def change
    create_table :coupons do |t|
      t.references :merchant, foreign_key: true          # Adds merchant_id as a foreign key
      t.string :name                                     # Name of the coupon
      t.string :code, unique: true                       # Unique coupon code (e.g., "BOGO50")
      t.string :discount_type                            # Type of discount (e.g., "percent" or "dollar")
      t.decimal :discount_value                          # Value of the discount (e.g., 50 for 50% or $10 off)
      t.boolean :active, default: true                   # Status of the coupon (active/inactive)

      t.timestamps                                       # Adds created_at and updated_at timestamps
    end
  end
end
