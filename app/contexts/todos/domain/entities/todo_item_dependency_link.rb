module Todos
  module Domain
    module Entities
      class TodoItemDependencyLink
        attr_reader :id, :todo_item_id, :depends_on_id, :created_at

        def initialize(id:, todo_item_id:, depends_on_id:, created_at: nil)
          @id = id
          @todo_item_id = todo_item_id
          @depends_on_id = depends_on_id
          @created_at = created_at

          validate!
        end

        private

        def validate!
          return if todo_item_id.present? && depends_on_id.present? && todo_item_id != depends_on_id

          raise Todos::Domain::Errors::ValidationError, 'Invalid dependency'
        end
      end
    end
  end
end