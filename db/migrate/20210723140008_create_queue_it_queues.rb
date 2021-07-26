class CreateQueueItQueues < ActiveRecord::Migration[6.1]
  def change
    create_table :queue_it_queues do |t|
      t.references :queable, polymorphic: true

      t.timestamps
    end
  end
end
