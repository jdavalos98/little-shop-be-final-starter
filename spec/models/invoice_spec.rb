require 'rails_helper'

RSpec.describe Invoice, type: :model do
  describe "associations" do
    it { should belong_to(:merchant) }
    it { should belong_to(:customer) }
    it { should belong_to(:coupon).optional }
  end

  describe "validations" do
    it { should validate_presence_of(:status) }
    it { should validate_inclusion_of(:status).in_array(%w[pending shipped canceled]) }
  end
end