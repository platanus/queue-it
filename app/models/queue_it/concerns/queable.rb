module QueueIt::Concerns::Queable
  extend ActiveSupport::Concern

  included do
    has_one :queue,
            as: :queable, inverse_of: :queable, dependent: :destroy, class_name: 'QueueIt::Queue'

    def find_or_create_queue!
      QueueIt::Queue.find_or_create_by!(queable: self)
    end

    def push_to_queue(nodable, in_head = true)
      if local_queue.nodes.count.zero?
        local_queue.nodes.create!(nodable: nodable, kind: :head, queue: local_queue)
      elsif local_queue.nodes.count == 1
        push_node_when_queue_lenght_is_one(nodable, in_head)
      else
        in_head ? push_in_head(nodable) : push_in_tail(nodable)
      end
    end

    def get_next_in_queue
      return if local_queue.length.zero?

      if local_queue.length == 1
        local_queue.head_node
      elsif local_queue.length == 2
        get_next_in_queue_with_length_two
      else
        get_next_in_queue_generic
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

    def get_next_in_queue_with_length_two
      old_head_node = local_queue.head_node
      old_tail_node = local_queue.tail_node
      ActiveRecord::Base.transaction do
        local_queue.nodes.where.not(kind: :any).update_all(kind: :any)
        old_head_node.update!(kind: :tail, parent_node: old_tail_node)
        old_tail_node.update!(kind: :head, parent_node: nil)
      end
      old_head_node
    end

    def get_next_in_queue_generic
      old_head_node = local_queue.head_node
      old_second_node = old_head_node.child_node
      old_tail_node = local_queue.tail_node
      ActiveRecord::Base.transaction do
        local_queue.nodes.where.not(kind: :any).update_all(kind: :any)
        old_head_node.update!(kind: :tail, parent_node: old_tail_node)
        old_second_node.update!(kind: :head, parent_node: nil)
      end
      old_head_node
    end

    def push_node_when_queue_lenght_is_one(nodable, in_head)
      if in_head
        push_in_head(nodable)
      else
        local_queue.nodes.create!(
          nodable: nodable, kind: :tail, queue: local_queue, parent_node: local_queue.head_node
        )
      end
    end

    def push_in_head(nodable)
      old_head_node = local_queue.head_node
      ActiveRecord::Base.transaction do
        kind = local_queue.nodes.count == 1 ? :tail : :any
        old_head_node.update!(kind: kind)
        new_head_node = local_queue.nodes.create!(nodable: nodable, kind: :head, queue: local_queue)
        old_head_node.update!(parent_node: new_head_node)
      end
    end

    def push_in_tail(nodable)
      old_tail_node = local_queue.tail_node
      ActiveRecord::Base.transaction do
        old_tail_node.update!(kind: :any)
        new_tail_node = local_queue.nodes.create!(nodable: nodable, kind: :tail, queue: local_queue)
        old_tail_node.update!(parent_node: new_tail_node)
      end
    end
  end
end
