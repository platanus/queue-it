module QueueIt::Queable
  extend ActiveSupport::Concern

  included do
    has_one :queue,
            as: :queable, inverse_of: :queable, dependent: :destroy, class_name: 'QueueIt::Queue'

    def find_or_create_queue!
      QueueIt::Queue.find_or_create_by!(queable: self)
    end

    def push_to_queue(nodable, in_head = true)
      if local_queue.empty?
        local_queue.push_node_when_queue_length_is_zero(nodable)
      elsif local_queue.one_node?
        local_queue.push_node_when_queue_length_is_one(nodable, in_head)
      else
        in_head ? local_queue.push_in_head(nodable) : local_queue.push_in_tail(nodable)
      end
    end

    def get_next_in_queue
      get_next_node_in_queue&.nodable
    end

    def get_next_node_in_queue
      return if local_queue.empty?

      if local_queue.one_node?
        local_queue.head_node
      elsif local_queue.two_nodes?
        local_queue.get_next_in_queue_with_length_two
      else
        local_queue.get_next_in_queue_generic
      end
    end

    def formatted_queue(nodable_attribute)
      return if local_queue.empty?

      if local_queue.one_node?
        [local_queue.head_node.nodable.send(nodable_attribute)]
      elsif local_queue.two_nodes?
        [local_queue.head_node.nodable.send(nodable_attribute),
          local_queue.tail_node.nodable.send(nodable_attribute)]
      else
        current_node = local_queue.head_node
        array = []
        while !current_node.nil?
          array.push(current_node.nodable.send(nodable_attribute))
          current_node = current_node.child_node
        end
        array
      end
    end

    def delete_queue_nodes
      queue.nodes.delete_all
    end

    def remove_from_queue(nodable)
      return if local_queue.empty? || local_queue.nodes.where(nodable: nodable).empty?

      ActiveRecord::Base.transaction do
        local_queue.lock!
        local_queue.nodes.where(nodable: nodable).find_each do |node|
          remove_node(node)
        end
      end
    end

    private

    def local_queue
      @local_queue ||= find_or_create_queue!
    end

    def remove_node(node)
      node.reload
      previous_node = node.parent_node
      child_node = node.child_node
      kind = child_node&.tail? && !node.head? ? child_node.kind : node.kind
      node.destroy
      child_node&.update!(parent_node: previous_node, kind: kind)
      previous_node&.update!(kind: kind) if kind == 'tail' && previous_node&.any?
    end
  end
end
