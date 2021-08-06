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
        local_queue.nodes.create!(nodable: nodable, kind: :head, queue: local_queue)
      elsif local_queue.one_node?
        local_queue.push_node_when_queue_lenght_is_one(nodable, in_head)
      else
        in_head ? local_queue.push_in_head(nodable) : local_queue.push_in_tail(nodable)
      end
    end

    def get_next_in_queue
      return if local_queue.empty?

      if local_queue.one_node?
        local_queue.head_node
      elsif local_queue.two_nodes?
        local_queue.get_next_in_queue_with_length_two
      else
        local_queue.get_next_in_queue_generic
      end
    end

    def formatted_queue(node_attribute)
      return if local_queue.empty?

      if local_queue.one_node?
        [local_queue.head_node.nodable.send(node_attribute)]
      elsif local_queue.two_nodes?
        [local_queue.head_node.nodable.send(node_attribute) +
          local_queue.tail_node.nodable.send(node_attribute)]
      else
        current_node = local_queue.head_node
        array = []
        while !current_node.nil?
          array.push(current_node.nodable.send(node_attribute))
          current_node = current_node.child_node
        end
        array
      end
    end

    def empty_queue
      queue.nodes.delete_all
    end

    def delete_node(position)
      raise Error('The queue is empty') if queue.nodes.zero?
      raise Error('position out of lenght or invalid') if position > queue.nodes.lenght - 1
      # SIEMPRE TENEMOS 3 CASOS A NIVEL DE LISTA Y NIVEL DE POSICIONES:
      # A NIVEL DE LISTAS: LA LISTA TIENEN 1, 2 O MÁS NODOS
      # A NIVEL POSICIÓN ES LA CABEZA, LA COLA O CUALQUIER OTRO
    end

    private

    def local_queue
      @local_queue ||= find_or_create_queue!
    end
  end
end
