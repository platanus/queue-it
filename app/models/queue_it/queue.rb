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

    def length
      nodes.length
    end
  end
end
