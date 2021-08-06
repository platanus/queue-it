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

    def get_next_in_queue_with_length_two
      next_node = ActiveRecord::Base.transaction do
        old_head_node = head_node
        old_tail_node = tail_node
        nodes.where.not(kind: :any).each { |node| node.update!(kind: :any) }
        old_head_node.update!(kind: :tail, parent_node: old_tail_node)
        old_tail_node.update!(kind: :head, parent_node: nil)
        old_head_node
      end
      next_node
    end

    def get_next_in_queue_generic
      next_node = ActiveRecord::Base.transaction do
        old_head_node = head_node
        old_second_node = old_head_node.child_node
        old_tail_node = tail_node
        nodes.where.not(kind: :any).find_each { |node| node.update!(kind: :any) }
        old_head_node.update!(kind: :tail, parent_node: old_tail_node)
        old_second_node.update!(kind: :head, parent_node: nil)
        old_head_node
      end
      next_node
    end

    def push_node_when_queue_lenght_is_one(nodable, in_head)
      if in_head
        push_in_head(nodable)
      else
        nodes.create!(nodable: nodable, kind: :tail, parent_node: head_node)
      end
    end

    def push_in_head(nodable)
      ActiveRecord::Base.transaction do
        old_head_node = head_node
        kind = one_node? ? :tail : :any
        old_head_node.update!(kind: kind)
        new_head_node = nodes.create!(nodable: nodable, kind: :head)
        old_head_node.update!(parent_node: new_head_node)
      end
    end

    def push_in_tail(nodable)
      ActiveRecord::Base.transaction do
        old_tail_node = tail_node
        old_tail_node.update!(kind: :any)
        new_tail_node = nodes.create!(nodable: nodable, kind: :tail)
        old_tail_node.update!(parent_node: new_tail_node)
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
