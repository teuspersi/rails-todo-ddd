module Todos
  module Infrastructure
    module Persistence
      module ActiveRecord
        class TodoItemDependencyRecord < ::ApplicationRecord
          self.table_name = 'todo_item_dependencies'

          belongs_to :todo_item_record,
                     class_name: 'Todos::Infrastructure::Persistence::ActiveRecord::TodoItemRecord',
                     foreign_key: :todo_item_id

          belongs_to :depends_on_record,
                     class_name: 'Todos::Infrastructure::Persistence::ActiveRecord::TodoItemRecord',
                     foreign_key: :depends_on_id

          validates :todo_item_id, presence: true
          validates :depends_on_id, presence: true
          validate :prevent_self_dependency

          private

          def prevent_self_dependency
            if todo_item_id == depends_on_id
              errors.add(:base, 'Item cannot depend on itself')
            end
          end
        end
      end
    end
  end
end
