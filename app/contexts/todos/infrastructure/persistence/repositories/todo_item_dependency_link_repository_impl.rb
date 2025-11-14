module Todos
  module Infrastructure
    module Persistence
      module Repositories
        class TodoItemDependencyLinkRepositoryImpl < Todos::Domain::Repositories::TodoItemDependencyLinkRepository
          def create(todo_item_id, depends_on_id)
            record = record_class.create!(
              todo_item_id: todo_item_id,
              depends_on_id: depends_on_id
            )
            
            Todos::Domain::Entities::TodoItemDependencyLink.new(
              id: record.id,
              todo_item_id: record.todo_item_id,
              depends_on_id: record.depends_on_id,
              created_at: record.created_at
            )
          end

          def delete_by_todo_item(todo_item_id)
            record_class.where(todo_item_id: todo_item_id).destroy_all
          end

          def delete_by_depends_on(depends_on_id)
            record_class.where(depends_on_id: depends_on_id).destroy_all
          end

          private

          def record_class
            Todos::Infrastructure::Persistence::ActiveRecord::TodoItemDependencyLinkRecord
          end
        end
      end
    end
  end
end
  