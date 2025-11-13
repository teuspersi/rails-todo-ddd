module Todos
  module Domain
    module Entities
      class TodoItem
        attr_reader :id, :title, :due_date, :created_at, :updated_at
        attr_accessor :dependencies, :dependents

        def initialize(id:, title:, due_date:, created_at: nil, updated_at: nil)
          @id = id
          @title = title
          @due_date = due_date
          @created_at = created_at
          @updated_at = updated_at
          @dependencies = []
          @dependents = []

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
