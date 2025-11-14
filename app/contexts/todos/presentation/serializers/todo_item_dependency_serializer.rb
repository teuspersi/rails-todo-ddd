module Todos
  module Presentation
    module Serializers
      class TodoItemDependencySerializer
        def initialize(todo_item)
          @todo_item = todo_item
        end

        def as_json
          {
            id: @todo_item.id,
            title: @todo_item.title,
            due_date: @todo_item.due_date
          }
        end
      end
    end
  end
end
