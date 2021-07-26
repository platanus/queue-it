module QueueIt
  class Node < ApplicationRecord
    belongs_to :nodable, polymorphic: true
    belongs_to :queue, optional: true
    belongs_to :parent_node, class_name: 'QueueIt::Node', optional: true
    has_one :child_node,
            class_name: 'QueueIt::Node',
            dependent: :nullify,
            foreign_key: 'parent_node_id',
            inverse_of: :parent_node

    enum kind: { head: 0, any: 1, tail: 2 }

    validate :only_one_head, :only_one_tail

    def only_one_head
      # binding.pry
      if changes['kind'].present? && changes['kind'].first == 'any' &&
          changes['kind'].last == 'head' && queue.nodes.where(kind: :head).positive?
        errors.add(:kind, 'There can not be more than 1 head node in each queue')
      end
    end

    def only_one_tail
      if changes['kind'].present? && changes['kind'].first == 'any' &&
          changes['kind'].last == 'tail' && queue.nodes.where(kind: :head).positive?
        errors.add(:kind, 'There can not be more than 1 tail node in each queue')
      end
    end
  end
end
