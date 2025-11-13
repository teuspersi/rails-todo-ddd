class CreateTodoItemDependencies < ActiveRecord::Migration[6.1]
  def change
    create_table :todo_item_dependencies do |t|
      t.references :todo_item, null: false, foreign_key: true, index: true
      t.references :depends_on, null: false, foreign_key: { to_table: :todo_items }, index: true

      t.timestamps
    end

    add_index :todo_item_dependencies, [:todo_item_id, :depends_on_id], unique: true, name: 'index_todo_dependencies_unique'
  end
end
