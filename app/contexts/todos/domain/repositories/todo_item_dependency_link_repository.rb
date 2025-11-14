module Todos
  module Domain
    module Repositories
      class TodoItemDependencyLinkRepository
        def create(todo_item_id, depends_on_id)
          raise NotImplementedError
        end

        def delete_by_todo_item(todo_item_id)
          raise NotImplementedError
        end

        def delete_by_depends_on(depends_on_id)
          raise NotImplementedError
        end
      end
    end
  end
end
