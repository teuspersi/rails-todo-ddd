module Todos
  module Presentation
    module Serializers
      class TodoItemSerializer
        def initialize(todo_item)
          @todo_item = todo_item
        end

        def as_json
          {
            id: @todo_item.id,
            title: @todo_item.title,
            due_date: @todo_item.due_date,
            completed: @todo_item.completed,
            created_at: @todo_item.created_at,
            updated_at: @todo_item.updated_at,
            dependencies: @todo_item.dependencies.map { |dep| TodoItemDependencySerializer.new(dep).as_json },
            dependents: @todo_item.dependents.map { |dep| TodoItemDependencySerializer.new(dep).as_json }
          }
        end

        def self.collection(todo_items)
          todo_items.map { |item| new(item).as_json }
        end
      end
    end
  end
end
