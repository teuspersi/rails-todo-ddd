module Todos
  module Application
    module Services
      class DeleteTodoItemService
        def initialize(
          todo_item_repository: default_todo_item_repository,
          dependency_repository: default_dependency_repository
        )
          @todo_item_repository = todo_item_repository
          @dependency_repository = dependency_repository
        end

        def call(id)
          ::ActiveRecord::Base.transaction do
            todo_item = find_todo_item(id)
            remove_all_dependency_links(todo_item.id)
            @todo_item_repository.delete(todo_item.id)
          end
        end

        private

        def find_todo_item(id)
          todo_item = @todo_item_repository.find_by_id(id)
          raise Todos::Domain::Errors::RecordNotFoundError, 'Todo item not found' if todo_item.nil?

          todo_item
        end

        def remove_all_dependency_links(todo_item_id)
          @dependency_repository.delete_by_todo_item(todo_item_id)
          @dependency_repository.delete_by_depends_on(todo_item_id)
        end

        def default_todo_item_repository
          Todos::Infrastructure::Persistence::Repositories::TodoItemRepositoryImpl.new
        end

        def default_dependency_repository
          Todos::Infrastructure::Persistence::Repositories::TodoItemDependencyLinkRepositoryImpl.new
        end
      end
    end
  end
end
