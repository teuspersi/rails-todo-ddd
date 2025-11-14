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

ActiveRecord::Schema.define(version: 2025_11_14_144429) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "todo_item_dependency_links", force: :cascade do |t|
    t.bigint "todo_item_id", null: false
    t.bigint "depends_on_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["depends_on_id"], name: "index_todo_item_dependency_links_on_depends_on_id"
    t.index ["todo_item_id", "depends_on_id"], name: "index_todo_dependencies_unique", unique: true
    t.index ["todo_item_id"], name: "index_todo_item_dependency_links_on_todo_item_id"
  end

  create_table "todo_items", force: :cascade do |t|
    t.string "title", null: false
    t.date "due_date", null: false
    t.boolean "completed", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "todo_item_dependency_links", "todo_items"
  add_foreign_key "todo_item_dependency_links", "todo_items", column: "depends_on_id"
end
