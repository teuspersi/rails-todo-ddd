module Todos
  module Infrastructure
    module Mappers
      class TodoItemMapper
        def self.to_entity(record, include_relations: false)
          return nil unless record

          entity = Todos::Domain::Entities::TodoItem.new(
            id: record.id,
            title: record.title,
            due_date: record.due_date,
            completed: record.completed,
            created_at: record.created_at,
            updated_at: record.updated_at
          )

          if include_relations
            entity.dependencies = record.dependency_records.map { |dep| to_entity(dep, include_relations: false) }
            entity.dependents = record.dependent_records.map { |dep| to_entity(dep, include_relations: false) }
          end

          entity
        end

        def self.to_record_attributes(entity)
          {
            title: entity.title,
            due_date: entity.due_date,
            completed: entity.completed
          }
        end
      end
    end
  end
end
