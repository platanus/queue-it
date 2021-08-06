class AddCountOfNodesColumnToQueue < ActiveRecord::Migration[6.1]
  def change
    add_column :queue_it_queues, :count_of_nodes, :bigint, default: 0
  end
end
