require 'rails_helper'

RSpec.describe Expense, type: :model do
  let(:expense) { build(:expense) }
    
    it { is_expected.to belong_to(:user) }
    it { is_expected.to validate_presence_of :description }
    it { is_expected.to validate_presence_of :user_id }
    
    it { is_expected.to respond_to(:description) }
    it { is_expected.to respond_to(:value) }
    it { is_expected.to respond_to(:date) }
    it { is_expected.to respond_to(:user_id) }
end
