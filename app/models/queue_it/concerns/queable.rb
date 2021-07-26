module QueueIt::Concerns::Queable
  extend ActiveSupport::Concern

  included do
    has_one :queue,
            as: :queable, inverse_of: :queable, dependent: :destroy, class_name: 'QueueIt::Queue'

    def push_to_queue(nodable, in_head = true)
      if queue.nodes.count.zero?
        queue.nodes.create!(nodable: nodable, kind: :head, queue: queue)
      elsif queue.nodes.count == 1
        push_node_when_queue_lenght_is_one(nodable, in_head)
      else
        in_head ? push_in_head(nodable) : push_in_tail(nodable)
      end
    end

    def get_next_in_queue
      return if queue.length.zero?

      old_head_node = queue.head_node
      old_second_node = head_node.child_node
      old_tail_node = queue.tail_node
      ActiveRecord::Base.transaction do
        queue.nodes.where.not(kind: :any).update_all!(kind: :any)
        old_head_node.update!(kind: :tail, parent_node: old_tail_node)
        old_second_node.update!(kind: :head, parent_node: nil)
      end
      old_head_node
    end

    def delete_queue
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

    def get_next_in_queue_with_lenth_one
    end

    def get_next_in_queue_with_lenth_two
    end

    def delete_head_node
    end

    def delete_tail_node
    end

    def push_node_when_queue_lenght_is_one(nodable, in_head)
      if in_head
        push_in_head(nodable)
      else
        queue.nodes.create!(
          nodable: nodable, kind: :tail, queue: queue, parent_node: queue.head_node
        )
      end
    end

    def push_in_head(nodable)
      old_head_node = queue.head_node
      ActiveRecord::Base.transaction do
        kind = queue.nodes.count == 1 ? :tail : :any
        old_head_node.update!(kind: kind)
        new_head_node = queue.nodes.create!(nodable: nodable, kind: :head, queue: queue)
        old_head_node.update!(parent_node: new_head_node)
      end
      # should i add a `queue.nodes.reload`?
    end

    def push_in_tail(nodable)
      old_tail_node = queue.tail_node
      ActiveRecord::Base.transaction do
        old_tail_node.update!(kind: :any)
        new_tail_node = queue.nodes.create!(nodable: nodable, kind: :tail, queue: queue)
        old_tail_node.update!(parent_node: new_tail_node)
      end
    end
  end
end
