module Todos
  module Domain
    module Entities
      class TodoItem
        attr_reader :id, :title, :due_date, :completed, :created_at, :updated_at
        attr_accessor :dependencies, :dependents

        def initialize(id:, title:, due_date:, completed: false, created_at: nil, updated_at: nil)
          @id = id
          @title = title
          @due_date = due_date
          @completed = completed
          @created_at = created_at
          @updated_at = updated_at
          @dependencies = []
          @dependents = []

          validate!
        end

        def validate!
          return if title.present? && due_date.present?
          
          raise Todos::Domain::Errors::ValidationError, 'Title and due date are required'
        end

        def depends_on?(other_item)
          dependencies.any? { |dep| dep.id == other_item.id } ||
            dependencies.any? { |dep| dep.depends_on?(other_item) }
        end

        def update_title(new_title)
          raise Todos::Domain::Errors::ArgumentError, "Title cannot be blank" if new_title.blank?
          @title = new_title
        end

        def update_due_date(new_due_date)
          raise Todos::Domain::Errors::ArgumentError, "Due date cannot be blank" if new_due_date.blank?
          @due_date = new_due_date
        end

        def update_completed(new_completed)
          raise Todos::Domain::Errors::ArgumentError, "Completed cannot be blank" if new_completed.blank?
          @completed = new_completed
        end
      end
    end
  end
end
