class CreateQueueItNodes < ActiveRecord::Migration[6.1]
  def change
    create_table :queue_it_nodes do |t|
      t.references :nodable, polymorphic: true
      t.references :queue
      t.references :parent_node
      t.integer :kind

      t.timestamps
    end
  end
end
