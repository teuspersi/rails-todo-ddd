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

        def find_many_with_dependencies(ids)
          raise NotImplementedError
        end

        def find_all
          raise NotImplementedError
        end

        def update(todo_item)
          raise NotImplementedError
        end

        def batch_update_due_dates(item_ids, date_diff)
          raise NotImplementedError
        end

        def find_dependent_ids(item_id)
          raise NotImplementedError
        end

        def delete(id)
          raise NotImplementedError
        end
      end
    end
  end
end
