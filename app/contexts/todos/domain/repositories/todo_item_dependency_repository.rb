module Todos
  module Domain
    module Repositories
      class TodoItemDependencyRepository
        def create(todo_item_id, depends_on_id)
          raise NotImplementedError
        end
      end
    end
  end
end
