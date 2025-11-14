module Todos
  module Application
    module Services
      class ListTodoItemsService
        def initialize(todo_item_repository: default_todo_item_repository)
          @todo_item_repository = todo_item_repository
        end

        def call
          @todo_item_repository.find_all
        end

        private

        def default_todo_item_repository
          Todos::Infrastructure::Persistence::Repositories::TodoItemRepositoryImpl.new
        end
      end
    end
  end
end
