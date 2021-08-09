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

    describe '#get_next_in_queue_with_length_two' do
      let(:queue) { create(:queue, :with_two_nodes) }
      let!(:original_head) { queue.head_node }
      let!(:original_tail) { queue.tail_node }

      it { expect(queue.get_next_in_queue_with_length_two).to eq(original_head) }

      it 'expect original head to be the tail node' do
        queue.get_next_in_queue_with_length_two
        expect(queue.tail_node).to eq(original_head)
        expect(original_head.child_node).to be(nil)
      end

      it 'expects original tail node to be head node' do
        queue.get_next_in_queue_with_length_two
        expect(queue.head_node).to eq(original_tail)
        expect(original_tail.reload.child_node).to eq(original_head.reload)
      end
    end

    describe '#get_next_in_queue_generic' do
      let(:queue) { create(:queue, :with_three_nodes) }
      let!(:original_head) { queue.head_node }
      let!(:original_any) { queue.head_node.child_node }
      let!(:original_tail) { queue.tail_node }

      it { expect(queue.get_next_in_queue_with_length_two).to eq(original_head) }

      it 'expects original head to be the tail node' do
        queue.get_next_in_queue_generic
        expect(queue.tail_node).to eq(original_head)
        expect(original_head.child_node).to be(nil)
      end

      it 'expects orginal any to be the head node' do
        queue.get_next_in_queue_generic
        expect(queue.head_node).to eq(original_any)
        expect(original_any.reload.child_node).to eq(original_tail.reload)
        expect(original_tail.reload.child_node).to eq(original_head.reload)
      end

      it 'expects original tail node to be any node' do
        queue.get_next_in_queue_generic
        expect(queue.head_node.child_node).to eq(original_tail)
        expect(original_tail.reload.child_node).to eq(original_head.reload)
      end
    end

    describe '#push_node_when_queue_length_is_zero' do
      let(:queue) { create(:queue) }
      let(:nodable) { create(:user) }

      it 'expects nodable to be in head node' do
        queue.push_node_when_queue_length_is_zero(nodable)
        expect(queue.head_node.nodable).to eq(nodable)
      end
    end

    describe '#push_node_when_queue_length_is_one' do
      let(:queue) { create(:queue, :with_one_node) }
      let(:nodable) { create(:user) }
      let(:in_head) { true }

      it 'expects nodable to be in head node' do
        queue.push_node_when_queue_length_is_one(nodable, in_head)
        expect(queue.head_node.nodable).to eq(nodable)
      end

      context 'when in_head is false' do
        let(:in_head) { false }

        it 'expects nodable to be in tail node' do
          queue.push_node_when_queue_length_is_one(nodable, in_head)
          expect(queue.tail_node.nodable).to eq(nodable)
        end
      end
    end

    describe '#push_in_head' do
      let(:queue) { create(:queue, :with_one_node) }
      let(:nodable) { create(:user) }

      it 'expects nodable to be in head node' do
        queue.push_in_head(nodable)
        expect(queue.head_node.nodable).to eq(nodable)
      end
    end

    describe '#push_in_tail' do
      let(:queue) { create(:queue, :with_two_nodes) }
      let(:nodable) { create(:user) }

      it 'expects nodable to be in tail node' do
        queue.push_in_tail(nodable)
        expect(queue.tail_node.nodable).to eq(nodable)
      end
    end
  end
end
