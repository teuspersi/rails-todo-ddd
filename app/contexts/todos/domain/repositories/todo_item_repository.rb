module Todos
  module Domain
    module Repositories
      class TodoItemRepository
        def save(todo_item)
          raise NotImplementedError
        end

        def find_with_dependencies(id)
          raise NotImplementedError
        end
      end
    end
  end
end
