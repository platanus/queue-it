require 'rails_helper'

module QueueIt
  RSpec.describe Queue, type: :model do
    it "has a valid factory" do
      expect(build(:queue)).to be_valid
    end

    describe 'relations' do
      it { is_expected.to belong_to(:queable) }
      it { is_expected.to have_many(:nodes) }
    end
  end
end
