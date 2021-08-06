module QueueIt
  class Node < ApplicationRecord
    belongs_to :nodable, polymorphic: true
    belongs_to :queue, optional: true, counter_cache: :count_of_nodes
    belongs_to :parent_node, class_name: 'QueueIt::Node', optional: true
    has_one :child_node,
            class_name: 'QueueIt::Node',
            dependent: :nullify,
            foreign_key: 'parent_node_id',
            inverse_of: :parent_node

    enum kind: { head: 0, any: 1, tail: 2 }

    validate :only_one_head, :only_one_tail

    def only_one_head
      if repeated_kind?('head')
        errors.add(:kind, 'There can not be more than 1 head node in each queue')
      end
    end

    def only_one_tail
      if repeated_kind?('tail')
        errors.add(:kind, 'There can not be more than 1 tail node in each queue')
      end
    end

    def head?
      kind == 'head'
    end

    def tail?
      kind == 'tail'
    end

    private

    def repeated_kind?(kind)
      changes['kind'].present? && (changes['kind'].first == 'any' ||
        changes['kind'].first.nil?) && changes['kind'].last == kind &&
        queue.nodes.find_by(kind: kind).present?
    end
  end
end

# == Schema Information
#
# Table name: queue_it_nodes
#
#  id             :bigint(8)        not null, primary key
#  nodable_type   :string
#  nodable_id     :bigint(8)
#  queue_id       :bigint(8)
#  parent_node_id :bigint(8)
#  kind           :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_queue_it_nodes_on_nodable         (nodable_type,nodable_id)
#  index_queue_it_nodes_on_parent_node_id  (parent_node_id)
#  index_queue_it_nodes_on_queue_id        (queue_id)
#
