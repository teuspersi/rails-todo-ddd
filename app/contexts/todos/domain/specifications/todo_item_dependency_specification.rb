module Todos
  module Domain
    module Specifications
      class TodoItemDependencySpecification < BaseSpecification
        def initialize(todo_item, dependency)
          @todo_item = todo_item
          @dependency = dependency
        end

        def ensure_satisfied!
          check_dependency_exists!
          check_not_self_dependency!
          check_no_circular_dependency!
          check_due_date_order!
        end

        private

        def check_dependency_exists!
          return if @dependency.present?

          raise Todos::Domain::Errors::ValidationError.new('Dependency not found')
        end

        def check_not_self_dependency!
          return if @todo_item.id != @dependency.id

          raise Todos::Domain::Errors::ValidationError.new('Item cannot depend on itself')
        end

        def check_no_circular_dependency!
          return if !@dependency.depends_on?(@todo_item)

          raise Todos::Domain::Errors::ValidationError.new('Cannot create circular dependency')
        end

        def check_due_date_order!
          return if @todo_item.due_date > @dependency.due_date

          raise Todos::Domain::Errors::ValidationError.new("Due date must be after dependency's due date")
        end
      end
    end
  end
end
