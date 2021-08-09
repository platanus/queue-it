describe 'Concerns::Queable' do
  let(:task) { create(:task) }

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
        it 'expects first_noable to have second_nodable as parent_node and second_nodable to have third_nodable as parent_node' do
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
    end

    context 'when queue has two nodes' do
      let(:first_nodable) { create(:user) }
      let(:second_nodable) { create(:user) }
      let(:in_head) { true }

      before do
        task.push_to_queue(first_nodable)
        task.push_to_queue(second_nodable, in_head)
      end

      it "expects to return second_nodable node and to change node 'head' for 'tail' and reverse" do
        expect(task.get_next_node_in_queue.nodable).to eq(second_nodable)
        expect(task.queue.nodes.find_by(kind: :head).nodable).to eq(first_nodable)
        expect(task.queue.nodes.find_by(kind: :tail).nodable).to eq(second_nodable)
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

      it "expects to get third nodable and to correctly move the queue" do
        expect(task.get_next_node_in_queue.nodable).to eq(third_nodable)
        expect(task.queue.nodes.find_by(kind: :head).nodable).to eq(second_nodable)
        expect(task.queue.nodes.find_by(kind: :any).nodable).to eq(first_nodable)
        expect(task.queue.nodes.find_by(kind: :tail).nodable).to eq(third_nodable)
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

      it { expect { task.delete_queue_nodes }.not_to change { task.queue.size } }
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
end
