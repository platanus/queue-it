require 'rails_helper'

# rubocop:disable Metrics/ModuleLength
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

    describe '#get_next_by_with_queue_length_two' do
      let(:queue) { create(:queue, :with_two_nodes) }
      let!(:original_head) { queue.head_node }
      let!(:original_tail) { queue.tail_node }

      context 'when searching for tail node' do
        it "expects to return original_tail and to not change nodables kind's" do
          expect(
            queue.get_next_by_with_queue_length_two('id', original_tail.nodable_id)
          ).to eq(original_tail)
          expect(queue.nodes.find_by(kind: :head)).to eq(original_head)
          expect(queue.nodes.find_by(kind: :tail)).to eq(original_tail)
        end
      end

      context 'when searching for head node' do
        it "expects to return original_head node and to change node 'head' for 'tail' and
            reverse" do
          expect(
            queue.get_next_by_with_queue_length_two('id', original_head.nodable.id)
          ).to eq(original_head)
          expect(queue.nodes.find_by(kind: :head)).to eq(original_tail)
          expect(queue.nodes.find_by(kind: :tail)).to eq(original_head)
        end
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

    describe '#get_next_by_in_generic_queue' do
      let(:queue) { create(:queue, :with_three_nodes) }
      let!(:original_head) { queue.head_node }
      let!(:original_any) { queue.head_node.child_node }
      let!(:original_tail) { queue.tail_node }

      context 'when searching for the head_node' do
        it "expects to get orginal_head and to correctly move the queue" do
          expect(
            queue.get_next_by_in_generic_queue('id', original_head.nodable_id)
          ).to eq(original_head)
          expect(queue.nodes.find_by(kind: :head)).to eq(original_any)
          expect(queue.nodes.find_by(kind: :any)).to eq(original_tail)
          expect(queue.nodes.find_by(kind: :tail)).to eq(original_head)
        end
      end

      context 'when searching for the middle node' do
        it "expects to get original_any and to correctly move the queue" do
          expect(
            queue.get_next_by_in_generic_queue('id', original_any.nodable_id)
          ).to eq(original_any)
          expect(queue.nodes.find_by(kind: :head)).to eq(original_head)
          expect(queue.nodes.find_by(kind: :any)).to eq(original_tail)
          expect(queue.nodes.find_by(kind: :tail)).to eq(original_any)
        end
      end

      context 'when searching for the tail node' do
        it "expects to get original_tail and to correctly move the queue" do
          expect(
            queue.get_next_by_in_generic_queue('id', original_tail.nodable.id)
          ).to eq(original_tail)
          expect(queue.nodes.find_by(kind: :head)).to eq(original_head)
          expect(queue.nodes.find_by(kind: :any)).to eq(original_any)
          expect(queue.nodes.find_by(kind: :tail)).to eq(original_tail)
        end
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
        old_head_node = queue.head_node
        queue.push_in_head(nodable)
        expect(queue.head_node.nodable).to eq(nodable)
        expect(old_head_node.reload.parent_node).to eq(queue.head_node)
      end
    end

    describe '#push_in_tail' do
      let(:queue) { create(:queue, :with_two_nodes) }
      let(:nodable) { create(:user) }

      it 'expects nodable to be in tail node' do
        old_tail_node = queue.tail_node
        queue.push_in_tail(nodable)
        expect(queue.tail_node.nodable).to eq(nodable)
        expect(queue.tail_node.parent_node).to eq(old_tail_node)
      end
    end
  end
end
# rubocop:enable Metrics/ModuleLength
