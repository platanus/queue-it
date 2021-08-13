class CreateQueueItQueues < ActiveRecord::Migration[6.1]
  def change
    create_table :queue_it_queues do |t|
      t.references :queable, polymorphic: true
      t.bigint :count_of_nodes, default: 0

      t.timestamps
    end
  end
end
