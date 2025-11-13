class CreateTodoItems < ActiveRecord::Migration[6.1]
  def change
    create_table :todo_items do |t|
      t.string :title, null: false
      t.date :due_date, null: false
      t.boolean :completed, default: false

      t.timestamps
    end
  end
end
