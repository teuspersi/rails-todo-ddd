module Todos
  module Domain
    module Entities
      class TodoItem
        attr_reader :id, :title, :due_date

        def initialize(id:, title:, due_date:)
          @id = id
          @title = title
          @due_date = due_date
        end

        def valid?
          @title.present? && @due_date.present?
        end
      end
    end
  end
end
