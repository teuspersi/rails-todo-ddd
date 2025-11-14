module Todos
  module Infrastructure
    module Persistence
      module ActiveRecord
        class TodoItemRecord < ::ApplicationRecord
          self.table_name = 'todo_items'

          has_many :todo_item_dependency_records,
                   class_name: 'Todos::Infrastructure::Persistence::ActiveRecord::TodoItemDependencyRecord',
                   foreign_key: :todo_item_id,
                   dependent: :destroy

          has_many :dependency_records,
                   through: :todo_item_dependency_records,
                   source: :depends_on_record

          has_many :dependent_todo_item_dependency_records,
                   class_name: 'Todos::Infrastructure::Persistence::ActiveRecord::TodoItemDependencyRecord',
                   foreign_key: :depends_on_id,
                   dependent: :destroy

          has_many :dependent_records,
                   through: :dependent_todo_item_dependency_records,
                   source: :todo_item_record

          validates :title, presence: true
          validates :due_date, presence: true
        end
      end
    end
  end
end
