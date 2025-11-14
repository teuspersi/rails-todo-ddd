class RenameTodoItemDependenciesToLinks < ActiveRecord::Migration[6.1]
  def change
    rename_table :todo_item_dependencies, :todo_item_dependency_links
  end
end
