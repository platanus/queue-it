# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_08_06_144346) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "queue_it_nodes", force: :cascade do |t|
    t.string "nodable_type"
    t.bigint "nodable_id"
    t.bigint "queue_id"
    t.bigint "parent_node_id"
    t.integer "kind"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["nodable_type", "nodable_id"], name: "index_queue_it_nodes_on_nodable"
    t.index ["parent_node_id"], name: "index_queue_it_nodes_on_parent_node_id"
    t.index ["queue_id"], name: "index_queue_it_nodes_on_queue_id"
  end

  create_table "queue_it_queues", force: :cascade do |t|
    t.string "queable_type"
    t.bigint "queable_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "count_of_nodes", default: 0
    t.index ["queable_type", "queable_id"], name: "index_queue_it_queues_on_queable"
  end

  create_table "tasks", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

end
