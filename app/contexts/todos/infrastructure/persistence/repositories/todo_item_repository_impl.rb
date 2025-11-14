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

          def find_all
            records = record_class
              .includes(:dependency_records, :dependent_records)
              .order(due_date: :asc)
            
            records.map { |record| Mappers::TodoItemMapper.to_entity(record, include_relations: true) }
          end

          def update(todo_item)
            record = record_class.find(todo_item.id)
            attributes = Mappers::TodoItemMapper.to_record_attributes(todo_item)
            record.update!(attributes)
            
            record.reload
            Mappers::TodoItemMapper.to_entity(record, include_relations: false)
          end

          def batch_update_due_dates(item_ids, date_diff)
            return if item_ids.empty?
            
            record_class
              .where(id: item_ids)
              .update_all("due_date = due_date + INTERVAL '#{date_diff} days'")
          end

          def find_dependent_ids(item_id)
            dependency_link_record_class
              .where(depends_on_id: item_id)
              .pluck(:todo_item_id)
          end

          def delete(id)
            record_class.destroy(id)
          end
          
          private

          def record_class
            Todos::Infrastructure::Persistence::ActiveRecord::TodoItemRecord
          end

          def dependency_link_record_class
            Todos::Infrastructure::Persistence::ActiveRecord::TodoItemDependencyLinkRecord
          end
        end
      end
    end
  end
end
