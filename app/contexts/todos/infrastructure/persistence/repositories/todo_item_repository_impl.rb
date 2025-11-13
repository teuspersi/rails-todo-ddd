module Todos
  module Infrastructure
    module Persistence
      module Repositories
        class TodoItemRepositoryImpl < Todos::Domain::Repositories::TodoItemRepository
          def save(todo_item)
            attributes = Mappers::TodoItemMapper.to_record_attributes(todo_item)
            record = record_class.create!(attributes)
            
            Mappers::TodoItemMapper.to_entity(record, include_relations: false)
          end

          def find_with_dependencies(id)
            record = record_class
              .includes(:dependency_records, :dependent_records)
              .find_by(id: id)
            
            return nil unless record

            Mappers::TodoItemMapper.to_entity(record, include_relations: true)
          end

          private

          def record_class
            Todos::Infrastructure::Persistence::ActiveRecord::TodoItemRecord
          end
        end
      end
    end
  end
end
