module Todos
  module Infrastructure
    module Persistence
      module Repositories
        class TodoItemDependencyRepositoryImpl < Todos::Domain::Repositories::TodoItemDependencyRepository
          def create(todo_item_id, depends_on_id)
            record = record_class.create!(
              todo_item_id: todo_item_id,
              depends_on_id: depends_on_id
            )
            
            Todos::Domain::Entities::TodoItemDependency.new(
              id: record.id,
              todo_item_id: record.todo_item_id,
              depends_on_id: record.depends_on_id,
              created_at: record.created_at
            )
          end

          private

          def record_class
            Todos::Infrastructure::Persistence::ActiveRecord::TodoItemDependencyRecord
          end
        end
      end
    end
  end
end
  