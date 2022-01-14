module QueueIt
  class Queue < ApplicationRecord
    belongs_to :queable, polymorphic: true
    has_many :nodes, dependent: :destroy

    def head_node
      nodes.find_by(kind: :head)
    end

    def tail_node
      nodes.find_by(kind: :tail)
    end

    def size
      nodes.size
    end

    def empty?
      size.zero?
    end

    def one_node?
      size == 1
    end

    def two_nodes?
      size == 2
    end

    def get_next_by_with_queue_length_one(nodable_attribute, attribute_value)
      head_node if head_node.nodable.send(nodable_attribute) == attribute_value
    end

    def get_next_by_with_queue_length_two(nodable_attribute, attribute_value)
      if head_node.nodable.send(nodable_attribute) == attribute_value
        get_next_in_queue_with_length_two
      elsif tail_node.nodable.send(nodable_attribute) == attribute_value
        tail_node
      end
    end

    def get_next_in_queue_with_length_two
      ActiveRecord::Base.transaction do
        lock!
        old_head_node = head_node.lock!
        old_tail_node = tail_node.lock!
        nodes.where.not(kind: :any).find_each { |node| node.update!(kind: :any) }
        old_head_node.update!(kind: :tail, parent_node: old_tail_node)
        old_tail_node.update!(kind: :head, parent_node: nil)
        old_head_node
      end
    end

    def get_next_by_in_generic_queue(nodable_attribute, attribute_value)
      if head_node.nodable.send(nodable_attribute) == attribute_value
        return get_next_in_queue_generic
      end

      current_node = head_node.child_node
      while !(current_node.nodable.send(nodable_attribute) == attribute_value &&
          current_node != tail_node)
        current_node = current_node.child_node
        break if current_node == tail_node
      end
      if current_node.nodable.send(nodable_attribute) == attribute_value
        current_node != tail_node ? move_current_node(current_node) : tail_node
      end
    end

    def get_next_in_queue_generic
      ActiveRecord::Base.transaction do
        lock!
        old_head_node = head_node.lock!
        old_second_node = old_head_node.child_node.lock!
        old_tail_node = tail_node.lock!
        nodes.where.not(kind: :any).find_each { |node| node.update!(kind: :any) }
        old_head_node.update!(kind: :tail, parent_node: old_tail_node)
        old_second_node.update!(kind: :head, parent_node: nil)
        old_head_node
      end
    end

    def push_node_when_queue_length_is_zero(nodable)
      ActiveRecord::Base.transaction do
        lock!
        nodes.create!(nodable: nodable, kind: :head)
      end
    end

    def push_node_when_queue_length_is_one(nodable, in_head)
      if in_head
        push_in_head(nodable)
      else
        ActiveRecord::Base.transaction do
          lock!
          nodes.create!(nodable: nodable, kind: :tail, parent_node: head_node)
        end
      end
    end

    def push_in_head(nodable)
      ActiveRecord::Base.transaction do
        lock!
        old_head_node = head_node.lock!
        kind = one_node? ? :tail : :any
        old_head_node.update!(kind: kind)
        new_head_node = nodes.create!(nodable: nodable, kind: :head)
        old_head_node.update!(parent_node: new_head_node)
      end
    end

    def push_in_tail(nodable)
      ActiveRecord::Base.transaction do
        lock!
        old_tail_node = tail_node.lock!
        old_tail_node.update!(kind: :any)
        nodes.create!(nodable: nodable, kind: :tail, parent_node: old_tail_node)
      end
    end

    private

    def move_current_node(current_node)
      ActiveRecord::Base.transaction do
        lock!
        old_parent_node = current_node.parent_node.lock!
        old_current_node = current_node.lock!
        old_next_node = current_node.child_node.lock!
        old_tail_node = tail_node.lock!
        old_tail_node.update!(kind: :any)
        old_current_node.update!(kind: :tail, parent_node: old_tail_node)
        old_next_node.update!(parent_node: old_parent_node)
        old_current_node
      end
    end
  end
end

# == Schema Information
#
# Table name: queue_it_queues
#
#  id             :bigint(8)        not null, primary key
#  queable_type   :string
#  queable_id     :bigint(8)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  count_of_nodes :bigint(8)        default(0)
#
# Indexes
#
#  index_queue_it_queues_on_queable  (queable_type,queable_id)
#
