module Todos
  module Domain
    module Entities
      class TodoItem
        attr_reader :id, :title, :due_date

        def initialize(id:, title:, due_date:)
          @id = id
          @title = title
          @due_date = due_date

          validate!
        end

        def validate!
          return if title.present? && due_date.present?
          
          raise Todos::Domain::Errors::ValidationError.new('Title and due date are required')
        end
      end
    end
  end
end
