require 'rails_helper'

module QueueIt
  RSpec.describe Node, type: :model do
    it "has a valid factory" do
      expect(build(:node, :head)).to be_valid
    end

    describe 'relations' do
      it { is_expected.to belong_to(:nodable) }
      it { is_expected.to belong_to(:queue).optional }
      it { is_expected.to belong_to(:parent_node).class_name('QueueIt::Node').optional }
      it { is_expected.to have_one(:child_node) }
    end

    describe 'validations' do
      let(:queue) { create(:queue) }
      let(:first_nodable) { create(:user) }
      let(:second_nodable) { create(:user) }
      let(:third_nodable) { create(:user) }

      def create_node(nodable, kind)
        create(:node, queue: queue, kind: kind, nodable: nodable)
      end

      describe 'when queue already has one head node' do
        let!(:node) { create(:node, queue: queue, nodable: first_nodable, kind: :head) }

        it 'expects to raise invalid record error' do
          expect { create_node(second_nodable, :head) }.to raise_error(ActiveRecord::RecordInvalid)
        end
      end

      describe 'when queue already has one tail node' do
        let!(:node) { create(:node, queue: queue, nodable: first_nodable, kind: :tail) }

        it 'expects to raise invalid record error' do
          expect { create_node(second_nodable, :tail) }.to raise_error(ActiveRecord::RecordInvalid)
        end
      end
    end
  end
end
