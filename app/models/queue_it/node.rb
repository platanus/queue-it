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
      if changes['kind'].present? && (changes['kind'].first == 'any' ||
          changes['kind'].first.nil?) && changes['kind'].last == 'head' &&
          queue.nodes.find_by(kind: :head).present?
        errors.add(:kind, 'There can not be more than 1 head node in each queue')
      end
    end

    def only_one_tail
      if changes['kind'].present? && (changes['kind'].first == 'any' ||
          changes['kind'].first == nil) && changes['kind'].last == 'tail' &&
          queue.nodes.find_by(kind: :tail).present?
        errors.add(:kind, 'There can not be more than 1 tail node in each queue')
      end
    end
  end
end
