module Todos
  module Application
    module Services
      class UpdateTodoItemService
        def initialize(todo_item_repository: default_todo_item_repository)
          @todo_item_repository = todo_item_repository
        end

        def call(id, params)
          ::ActiveRecord::Base.transaction do
            todo_item = @todo_item_repository.find_with_dependencies(id)
            raise RecordNotFoundErro, "Todo item not found" if todo_item.nil?

            update_todo_item(todo_item, params)
          end
        end

        private

        def update_todo_item(todo_item, params)
          todo_item.update_title(params[:title]) if params.key?(:title)
          todo_item.update_due_date(params[:due_date]) if params.key?(:due_date)
          todo_item.update_completed(params[:completed]) if params.key?(:completed)

          @todo_item_repository.update(todo_item)
        end

        def default_todo_item_repository
          Todos::Infrastructure::Persistence::Repositories::TodoItemRepositoryImpl.new
        end
      end
    end
  end
end
