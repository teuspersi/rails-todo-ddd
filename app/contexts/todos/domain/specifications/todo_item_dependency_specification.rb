module Todos
  module Domain
    module Specifications
      class TodoItemDependencySpecification < BaseSpecification
        def initialize(todo_item, dependency)
          @todo_item = todo_item
          @dependency = dependency
        end
        
        private

        def ensure_satisfied!
          raise NotImplementedError
        end
      end
    end
  end
end
