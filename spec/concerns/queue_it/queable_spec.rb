describe 'Concerns::Queable' do
  let(:task) { create(:task) }

  RSpec.shared_examples 'nodes_connected' do
    it 'expects to keep original connected nodes length
        (keep the structure after every action)' do
      task.send(action_callable, *action_arguments)
      expect(task.connected_nodes).to eq(task.queue.nodes.size)
    end
  end

  describe '#find_or_create_queue!' do
    before do
      task.find_or_create_queue!
    end

    it { expect(task.queue).not_to be(nil) }
  end

  describe '#push_to_queue' do
    context 'when queue is empty or not created' do
      let(:nodable) { create(:user) }

      before do
        task.push_to_queue(nodable)
      end

      it 'expect queue to not be empty' do
        expect(task.queue).not_to be(nil)
      end

      it 'expect head_node to be defined' do
        expect(task.queue.head_node).not_to be(nil)
      end

      it "expect head_node to be 'head' kind" do
        expect(task.queue.head_node.kind).to eq('head')
      end
    end

    context 'when queue has one previous node' do
      let(:first_nodable) { create(:user) }
      let(:second_nodable) { create(:user) }
      let(:in_head) { true }

      before do
        task.push_to_queue(first_nodable)
        task.push_to_queue(second_nodable, in_head)
      end

      context 'when node addition is in head (in_head is true)' do
        it "expects to add second_nodable as head and first_nodable to be kind 'tail'" do
          expect(task.queue.head_node.kind).to eq('head')
          expect(task.queue.tail_node.kind).to eq('tail')
        end

        it 'expects first_noable to have second_nodable as parent_node' do
          expect(task.queue.nodes.find_by(kind: :head).nodable).to eq(second_nodable)
          expect(task.queue.nodes.find_by(kind: :tail).nodable).to eq(first_nodable)
          expect(task.queue.nodes.find_by(kind: :tail).parent_node.nodable).to eq(second_nodable)
        end
      end

      context 'when node adition is in tail (in_head is false)' do
        let(:in_head) { false }

        it "expects to add second_nodable as kind 'tail' and first_nodable to still be head" do
          expect(task.queue.head_node.kind).to eq('head')
          expect(task.queue.tail_node.kind).to eq('tail')
        end

        it 'expects second_noable to have first_nodable as parent_node' do
          expect(task.queue.nodes.find_by(kind: :head).nodable).to eq(first_nodable)
          expect(task.queue.nodes.find_by(kind: :tail).nodable).to eq(second_nodable)
          expect(task.queue.nodes.find_by(kind: :tail).parent_node.nodable).to eq(first_nodable)
        end
      end
    end

    context 'when queue has more than one node' do
      let(:first_nodable) { create(:user) }
      let(:second_nodable) { create(:user) }
      let(:third_nodable) { create(:user) }
      let(:in_head) { true }

      before do
        task.push_to_queue(first_nodable)
        task.push_to_queue(second_nodable, in_head)
        task.push_to_queue(third_nodable, in_head)
      end

      context 'when node addition is in head (in_head is true)' do
        it 'expects first_noable to have second_nodable as parent_node and second_nodable to\
            have third_nodable as parent_node' do
          expect(task.queue.nodes.find_by(kind: :head).nodable).to eq(third_nodable)
          expect(task.queue.nodes.find_by(kind: :any).nodable).to eq(second_nodable)
          expect(task.queue.nodes.find_by(kind: :any).parent_node.nodable).to eq(third_nodable)
          expect(task.queue.nodes.find_by(kind: :tail).nodable).to eq(first_nodable)
          expect(task.queue.nodes.find_by(kind: :tail).parent_node.nodable).to eq(second_nodable)
        end
      end
    end
  end

  describe '#get_next_node_in_queue' do
    let(:action_callable) { 'get_next_node_in_queue' }
    let(:action_arguments) { [] }

    context "when queue dosen't exist or is empty" do
      it { expect(task.get_next_node_in_queue).to be(nil) }
    end

    context 'when queue has one node' do
      let(:nodable) { create(:user) }

      before { task.push_to_queue(nodable) }

      it "expects to find head_node and do not change it's kind value" do
        expect(task.get_next_node_in_queue.nodable).to eq(nodable)
        expect(task.queue.nodes.find_by(kind: :head).nodable).to eq(nodable)
      end

      include_examples 'nodes_connected'
    end

    context 'when queue has two nodes' do
      let(:first_nodable) { create(:user) }
      let(:second_nodable) { create(:user) }
      let(:in_head) { true }

      before do
        task.push_to_queue(first_nodable)
        task.push_to_queue(second_nodable, in_head)
      end

      it "expects to return second_nodable node and to change node 'head' for 'tail'"\
          "and reverse" do
        expect(task.get_next_node_in_queue.nodable).to eq(second_nodable)
        expect(task.queue.nodes.find_by(kind: :head).nodable).to eq(first_nodable)
        expect(task.queue.nodes.find_by(kind: :tail).nodable).to eq(second_nodable)
      end

      include_examples 'nodes_connected'
    end

    context 'when queue is generic (has more than two nodes)' do
      let(:first_nodable) { create(:user) }
      let(:second_nodable) { create(:user) }
      let(:third_nodable) { create(:user) }
      let(:in_head) { true }

      before do
        task.push_to_queue(first_nodable)
        task.push_to_queue(second_nodable, in_head)
        task.push_to_queue(third_nodable, in_head)
      end

      it "expects to get third nodable and to correctly move the queue" do
        expect(task.get_next_node_in_queue.nodable).to eq(third_nodable)
        expect(task.queue.nodes.find_by(kind: :head).nodable).to eq(second_nodable)
        expect(task.queue.nodes.find_by(kind: :any).nodable).to eq(first_nodable)
        expect(task.queue.nodes.find_by(kind: :tail).nodable).to eq(third_nodable)
      end

      include_examples 'nodes_connected'
    end
  end

  describe '#get_next_node_in_queue_by' do
    let!(:unused_nodable) { create(:user) }
    let(:action_callable) { 'get_next_node_in_queue_by' }

    RSpec.shared_examples 'missing_nodable' do
      context 'when searching for a nodable that is not present' do
        it 'expects to return nil' do
          expect(
            task.get_next_node_in_queue_by('id', unused_nodable.id)
          ).to eq(nil)
        end
      end
    end

    context "when queue dosen't exist or is empty" do
      include_examples 'missing_nodable'
    end

    context 'when queue has one node' do
      let(:nodable) { create(:user) }
      let(:action_arguments) { ['id', nodable.id] }

      before { task.push_to_queue(nodable) }

      it "expects to find head_node and do not change it's kind value" do
        expect(task.get_next_node_in_queue_by('id', nodable.id).nodable).to eq(nodable)
        expect(task.queue.nodes.find_by(kind: :head).nodable).to eq(nodable)
      end

      include_examples 'missing_nodable'
      include_examples 'nodes_connected'
    end

    context 'when queue has two nodes' do
      let!(:first_nodable) { create(:user) }
      let!(:second_nodable) { create(:user) }
      let(:in_head) { true }

      before do
        task.push_to_queue(first_nodable)
        task.push_to_queue(second_nodable, in_head)
      end

      context 'when searching for tail node' do
        let(:action_arguments) { ['id', first_nodable.id] }

        it "expects to return first_nodable and to not change nodables kind's" do
          expect(
            task.get_next_node_in_queue_by('id', first_nodable.id).nodable
          ).to eq(first_nodable)
          expect(task.queue.nodes.find_by(kind: :tail).nodable).to eq(first_nodable)
          expect(task.queue.nodes.find_by(kind: :head).nodable).to eq(second_nodable)
        end

        include_examples 'nodes_connected'
      end

      context 'when searching for head node' do
        let(:action_arguments) { ['id', second_nodable.id] }

        it "expects to return second_nodable node and to change node 'head' for 'tail'"\
            "and reverse" do
          expect(
            task.get_next_node_in_queue_by('id', second_nodable.id).nodable
          ).to eq(second_nodable)
          expect(task.queue.nodes.find_by(kind: :head).nodable).to eq(first_nodable)
          expect(task.queue.nodes.find_by(kind: :tail).nodable).to eq(second_nodable)
        end

        include_examples 'nodes_connected'
      end

      include_examples 'missing_nodable'
    end

    context 'when queue is generic (has more than two nodes)' do
      let(:first_nodable) { create(:user) }
      let(:second_nodable) { create(:user) }
      let(:third_nodable) { create(:user) }
      let(:in_head) { true }

      before do
        task.push_to_queue(first_nodable)
        task.push_to_queue(second_nodable, in_head)
        task.push_to_queue(third_nodable, in_head)
      end

      context 'when searching for the head_node' do
        let(:action_arguments) { ['id', third_nodable.id] }

        it "expects to get third nodable and to correctly move the queue" do
          expect(
            task.get_next_node_in_queue_by('id', third_nodable.id).nodable
          ).to eq(third_nodable)
          expect(task.queue.nodes.find_by(kind: :head).nodable).to eq(second_nodable)
          expect(task.queue.nodes.find_by(kind: :any).nodable).to eq(first_nodable)
          expect(task.queue.nodes.find_by(kind: :tail).nodable).to eq(third_nodable)
        end

        include_examples 'nodes_connected'
      end

      context 'when searching for the middle node' do
        let(:action_arguments) { ['id', second_nodable.id] }

        it "expects to get second nodable and to correctly move the queue" do
          expect(
            task.get_next_node_in_queue_by('id', second_nodable.id).nodable
          ).to eq(second_nodable)
          expect(task.queue.nodes.find_by(kind: :head).nodable).to eq(third_nodable)
          expect(task.queue.nodes.find_by(kind: :any).nodable).to eq(first_nodable)
          expect(task.queue.nodes.find_by(kind: :tail).nodable).to eq(second_nodable)
        end

        include_examples 'nodes_connected'
      end

      context 'when searching for the tail node' do
        let(:action_arguments) { ['id', first_nodable.id] }

        it "expects to get first nodable and to correctly move the queue" do
          expect(
            task.get_next_node_in_queue_by('id', first_nodable.id).nodable
          ).to eq(first_nodable)
          expect(task.queue.nodes.find_by(kind: :head).nodable).to eq(third_nodable)
          expect(task.queue.nodes.find_by(kind: :any).nodable).to eq(second_nodable)
          expect(task.queue.nodes.find_by(kind: :tail).nodable).to eq(first_nodable)
        end

        include_examples 'nodes_connected'
      end

      include_examples 'missing_nodable'
    end

    context 'when queue is generic and searching for second nodable in queue with 4 nodes' do
      let(:first_nodable) { create(:user) }
      let(:second_nodable) { create(:user) }
      let(:third_nodable) { create(:user) }
      let(:forth_nodable) { create(:user) }
      let(:in_head) { true }
      let(:action_arguments) { ['id', third_nodable.id] }

      before do
        task.push_to_queue(first_nodable)
        task.push_to_queue(second_nodable, in_head)
        task.push_to_queue(third_nodable, in_head)
        task.push_to_queue(forth_nodable, in_head)
      end

      it 'expects to move the order of the queue properly' do
        task.get_next_node_in_queue_by('id', third_nodable.id).nodable
        expect(task.queue.head_node.nodable).to eq(forth_nodable)
        expect(task.queue.head_node.child_node.nodable).to eq(second_nodable)
        expect(task.queue.tail_node.parent_node.nodable).to eq(first_nodable)
        expect(task.queue.tail_node.nodable).to eq(third_nodable)
      end

      include_examples 'nodes_connected'
      include_examples 'missing_nodable'
    end

    context 'when queue is generic and has two nodes with the same nodable' do
      let(:first_nodable) { create(:user) }
      let(:second_nodable) { create(:user) }
      let(:in_head) { true }

      before do
        task.push_to_queue(first_nodable)
        task.push_to_queue(second_nodable, in_head)
        task.push_to_queue(first_nodable, in_head)
      end

      context 'when searching for the the first_nodable' do
        let(:action_arguments) { ['id', first_nodable.id] }

        it "expects to get first nodable and to correctly move the queue" do
          expect(
            task.get_next_node_in_queue_by('id', first_nodable.id).nodable
          ).to eq(first_nodable)
          expect(task.queue.nodes.find_by(kind: :head).nodable).to eq(second_nodable)
          expect(task.queue.nodes.find_by(kind: :any).nodable).to eq(first_nodable)
          expect(task.queue.nodes.find_by(kind: :tail).nodable).to eq(first_nodable)
        end

        include_examples 'nodes_connected'
      end
    end

    context 'when queue is generic with more than 20 nodes' do
      let(:nodables) { create_list(:user, 20) }
      let(:selected_nodable) { nodables[10] }
      let(:in_head) { true }

      before do
        nodables.each { |nodable| task.push_to_queue(nodable, in_head) }
      end

      context 'when seraching for an specific node' do
        let(:action_arguments) { ['id', selected_nodable.id] }

        it 'expects to retrieve correct nodable and to move it to the tail' do
          expect(
            task.get_next_node_in_queue_by('id', selected_nodable.id).nodable
          ).to eq(selected_nodable)
          expect(task.queue.nodes.find_by(kind: :tail).nodable).to eq(selected_nodable)
        end

        include_examples 'nodes_connected'
      end
    end
  end

  describe '#formatted_queue' do
    let(:action_to_call) { 'name' }

    context "when queue dosen't exist or is empty" do
      it { expect(task.formatted_queue(action_to_call)).to be(nil) }
    end

    context 'when queue has one node' do
      let(:nodable) { create(:user) }

      before { task.push_to_queue(nodable) }

      it "expects to receive an array with nodable name" do
        expect(task.formatted_queue(action_to_call)).to eq([nodable.name])
      end
    end

    context 'when queue has two nodes' do
      let(:first_nodable) { create(:user) }
      let(:second_nodable) { create(:user) }
      let(:in_head) { true }

      before do
        task.push_to_queue(first_nodable)
        task.push_to_queue(second_nodable, in_head)
      end

      it "expects to receive array with second and first nodable's names" do
        expect(
          task.formatted_queue(action_to_call)
        ).to eq([second_nodable.name, first_nodable.name])
      end
    end

    context 'when queue is generic (has more than two nodes)' do
      let(:first_nodable) { create(:user) }
      let(:second_nodable) { create(:user) }
      let(:third_nodable) { create(:user) }
      let(:in_head) { true }

      before do
        task.push_to_queue(first_nodable)
        task.push_to_queue(second_nodable, in_head)
        task.push_to_queue(third_nodable, in_head)
      end

      it "expect to receive array with third, second and frist nodable's names" do
        expect(
          task.formatted_queue(action_to_call)
        ).to eq([third_nodable.name, second_nodable.name, first_nodable.name])
      end
    end
  end

  describe '#delete_queue_nodes' do
    context 'when queue is empty' do
      before { task.find_or_create_queue! }

      it { expect { task.delete_queue_nodes }.not_to (change { task.queue.size }) }
    end

    context 'when queue is with nodes' do
      let(:nodables) { create_list(:user, 5) }

      before do
        nodables.each do |nodable|
          task.push_to_queue(nodable)
        end
      end

      it { expect { task.delete_queue_nodes }.to change { task.queue.size }.from(5).to(0) }
    end
  end

  describe '#remove_from_queue' do
    context "when queue dosen't exist or is empty" do
      let(:nodable) { create(:user) }

      it { expect(task.remove_from_queue(nodable)).to be(nil) }
    end

    context "when queue does not have the nodable in it" do
      let(:task) { create(:task, :with_three_nodes) }
      let(:nodable) { create(:user) }

      it { expect(task.remove_from_queue(nodable)).to be(nil) }
    end

    context 'when queue has one node' do
      let(:nodable) { create(:user) }

      before { task.push_to_queue(nodable) }

      it "expects to find and delete the nodables node" do
        expect { task.remove_from_queue(nodable) }.to change { task.queue.size }.from(1).to(0)
      end
    end

    context 'when queue has two different nodables' do
      let(:first_nodable) { create(:user) }
      let(:second_nodable) { create(:user) }
      let(:in_head) { true }

      before do
        task.push_to_queue(first_nodable)
        task.push_to_queue(second_nodable, in_head)
      end

      it "expects to delete first_nodable" do
        expect do
          task.remove_from_queue(first_nodable)
        end.to change { task.queue.size }.from(2).to(1)
        expect(task.queue.head_node.nodable).to eq(second_nodable)
      end

      it "expects to delete second_nodable" do
        expect do
          task.remove_from_queue(second_nodable)
        end.to change { task.queue.size }.from(2).to(1)
        expect(task.queue.head_node.nodable).to eq(first_nodable)
      end

      context 'when the second_nodable is added in the tail' do
        let(:in_head) { false }

        it "expects to delete first_nodable" do
          expect do
            task.remove_from_queue(first_nodable)
          end.to change { task.queue.size }.from(2).to(1)
          expect(task.queue.head_node.nodable).to eq(second_nodable)
        end

        it "expects to delete second_nodable" do
          expect do
            task.remove_from_queue(second_nodable)
          end.to change { task.queue.size }.from(2).to(1)
          expect(task.queue.head_node.nodable).to eq(first_nodable)
        end
      end
    end

    context 'when queue has two equal nodables' do
      let(:nodable) { create(:user) }

      before do
        task.push_to_queue(nodable)
        task.push_to_queue(nodable)
      end

      it "expects to delte both nodes from the queue" do
        expect do
          task.remove_from_queue(nodable)
        end.to change { task.queue.size }.from(2).to(0)
      end
    end

    context 'when queue is generic (has more than two nodes)' do
      let(:first_nodable) { create(:user) }
      let(:second_nodable) { create(:user) }
      let(:third_nodable) { create(:user) }
      let(:in_head) { true }

      before do
        task.push_to_queue(first_nodable)
        task.push_to_queue(second_nodable, in_head)
        task.push_to_queue(third_nodable, in_head)
      end

      it "expects to delete first_nodable's node and to have second_nodable as tail" do
        expect do
          task.remove_from_queue(first_nodable)
        end.to change { task.queue.size }.from(3).to(2)
        expect(task.queue.tail_node.nodable).to eq(second_nodable)
      end

      it "expects to delete second_nodable's node and to have first_nodable as tail" do
        expect do
          task.remove_from_queue(second_nodable)
        end.to change { task.queue.size }.from(3).to(2)
        expect(task.queue.tail_node.nodable).to eq(first_nodable)
      end

      it "expects to delete third_nodable's node and to have second_nodable as head" do
        expect do
          task.remove_from_queue(third_nodable)
        end.to change { task.queue.size }.from(3).to(2)
        expect(task.queue.head_node.nodable).to eq(second_nodable)
      end

      context 'when nodes are added in the tail' do
        let(:in_head) { false }

        it "expects to delete first_nodable's node and to have second_nodable as tail" do
          expect do
            task.remove_from_queue(first_nodable)
          end.to change { task.queue.size }.from(3).to(2)
          expect(task.queue.head_node.nodable).to eq(second_nodable)
        end

        it "expects to delete second_nodable's node and to have first_nodable as tail" do
          expect do
            task.remove_from_queue(second_nodable)
          end.to change { task.queue.size }.from(3).to(2)
          expect(task.queue.tail_node.nodable).to eq(third_nodable)
        end

        it "expects to delete third_nodable's node and to have second_nodable as head" do
          expect do
            task.remove_from_queue(third_nodable)
          end.to change { task.queue.size }.from(3).to(2)
          expect(task.queue.tail_node.nodable).to eq(second_nodable)
        end
      end
    end

    context 'when queue has three nodes but two nodables are the same' do
      let(:first_nodable) { create(:user) }
      let(:second_nodable) { create(:user) }
      let(:in_head) { true }

      before do
        task.push_to_queue(first_nodable)
        task.push_to_queue(first_nodable, in_head)
        task.push_to_queue(second_nodable, in_head)
      end

      it "expects to delete first and second node when first_nodable is deleted" do
        expect do
          task.remove_from_queue(first_nodable)
        end.to change { task.queue.size }.from(3).to(1)
        expect(task.queue.head_node.nodable).to eq(second_nodable)
      end

      context 'when nodes are added in the tail' do
        let(:in_head) { false }

        it "expects to delete first and second node when first_nodable is deleted" do
          expect do
            task.remove_from_queue(first_nodable)
          end.to change { task.queue.size }.from(3).to(1)
          expect(task.queue.head_node.nodable).to eq(second_nodable)
        end
      end
    end

    context 'when queue has three nodes with the same nodable' do
      let(:nodable) { create(:user) }
      let(:in_head) { true }

      before do
        task.push_to_queue(nodable)
        task.push_to_queue(nodable)
        task.push_to_queue(nodable)
      end

      it "expects to delete first and second node when first_nodable is deleted" do
        expect { task.remove_from_queue(nodable) }.to change { task.queue.size }.from(3).to(0)
      end
    end

    context 'when queue has lenght 5' do
      let(:first_nodable) { create(:user) }
      let(:second_nodable) { create(:user) }
      let(:third_nodable) { create(:user) }
      let(:fourth_nodable) { create(:user) }
      let(:fifth_nodable) { create(:user) }
      let(:in_head) { true }

      before do
        task.push_to_queue(first_nodable)
        task.push_to_queue(second_nodable, in_head)
        task.push_to_queue(third_nodable, in_head)
        task.push_to_queue(fourth_nodable, in_head)
        task.push_to_queue(fifth_nodable, in_head)
      end

      RSpec.shared_examples "properly_removed" do
        it "expects not to raise an error and to properly delete de nodable's node" do
          expect { task.remove_from_queue(nodable_to_remove) }.to change {
            task.queue.size
          }.from(5).to(4)
        end
      end

      context 'when removing the the head_node of the queue (fifth_nodable)' do
        let(:nodable_to_remove) { fifth_nodable }

        include_examples 'properly_removed'

        it "expects head_node to have third_nodable as child_node" do
          task.remove_from_queue(fifth_nodable)
          expect(task.queue.head_node.nodable).to eq(fourth_nodable)
          expect(task.queue.head_node.child_node.nodable).to eq(third_nodable)
        end
      end

      context 'when removing the second nodable of the queue (fourth_nodable)' do
        let(:nodable_to_remove) { fourth_nodable }

        include_examples 'properly_removed'

        it "expects head_node to have third_nodable as child_node" do
          task.remove_from_queue(fourth_nodable)
          expect(task.queue.head_node.child_node.nodable).to eq(third_nodable)
        end
      end

      context 'when removing the third nodable of the queue (third_nodable)' do
        let(:nodable_to_remove) { third_nodable }

        include_examples 'properly_removed'

        it "expects fourth_nodable to have second_nodable as child_node" do
          task.remove_from_queue(third_nodable)
          expect(task.queue.head_node.child_node.nodable).to eq(fourth_nodable)
          expect(task.queue.head_node.child_node.child_node.nodable).to eq(second_nodable)
        end
      end

      context 'when removing the penultimaten (second_nodable)' do
        let(:nodable_to_remove) { second_nodable }

        include_examples 'properly_removed'

        it "expects tail_node to have third_nodable as parent_node" do
          task.remove_from_queue(second_nodable)
          expect(task.queue.tail_node.parent_node.nodable).to eq(third_nodable)
        end
      end

      context 'when removing the tail_node (first_nodable)' do
        let(:nodable_to_remove) { first_nodable }

        include_examples 'properly_removed'

        it "expects tail_node to have third_nodable as parent_node" do
          task.remove_from_queue(first_nodable)
          expect(task.queue.tail_node.nodable).to eq(second_nodable)
          expect(task.queue.tail_node.parent_node.nodable).to eq(third_nodable)
        end
      end
    end
  end
end
