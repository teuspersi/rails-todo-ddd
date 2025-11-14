module Todos
  module Application
    module Services
      class UpdateTodoItemService
        def initialize(
          todo_item_repository: default_todo_item_repository,
          dependency_repository: default_dependency_repository,
          dependency_specification: default_dependency_specification
        )
          @todo_item_repository = todo_item_repository
          @dependency_repository = dependency_repository
          @dependency_specification = dependency_specification
        end

        def call(id, params)
          ::ActiveRecord::Base.transaction do
            todo_item = find_todo_item(id)
            old_due_date = todo_item.due_date
            update_todo_item(todo_item, params)
            update_dependencies(todo_item, params[:dependency_ids]) if params.key?(:dependency_ids)
            if params.key?(:due_date) && old_due_date != todo_item.due_date
              cascade_due_date_update(todo_item, old_due_date, todo_item.due_date)
            end
            
            reload_todo_item(todo_item.id)
          end
        end

        private

        def find_todo_item(id)
          todo_item = @todo_item_repository.find_with_dependencies(id)
          raise RecordNotFoundErro, 'Todo item not found' if todo_item.nil?

          todo_item
        end

        def reload_todo_item(id)
          @todo_item_repository.find_with_dependencies(id)
        end

        def update_todo_item(todo_item, params)
          todo_item.update_title(params[:title]) if params.key?(:title)
          todo_item.update_due_date(params[:due_date]) if params.key?(:due_date)
          todo_item.update_completed(params[:completed]) if params.key?(:completed)

          validate_existing_dependencies(todo_item) unless params.key?(:dependency_ids)

          @todo_item_repository.update(todo_item)
        end

        def validate_existing_dependencies(todo_item)
          todo_item.dependencies.each do |dependency|
            @dependency_specification.new(todo_item, dependency).ensure_satisfied!
          end
        end

        def update_dependencies(todo_item, dependency_ids)
          @dependency_repository.delete_by_todo_item(todo_item.id)

          Array(dependency_ids).each do |dep_id|
            dependency = @todo_item_repository.find_with_dependencies(dep_id)

            @dependency_specification.new(todo_item, dependency).ensure_satisfied!

            @dependency_repository.create(todo_item.id, dependency.id)
          end
        end

        def cascade_due_date_update(todo_item, old_date, new_date)
          date_diff = (new_date - old_date).to_i
          
          cascade_service = Todos::Domain::Services::TodoItemDependencyCascadeService.new(@todo_item_repository)
          all_dependent_ids = cascade_service.collect_all_dependent_ids(todo_item.id)
          
          return if all_dependent_ids.empty?
          
          @todo_item_repository.batch_update_due_dates(all_dependent_ids, date_diff)
        end

        def default_todo_item_repository
          Todos::Infrastructure::Persistence::Repositories::TodoItemRepositoryImpl.new
        end

        def default_dependency_repository
          Todos::Infrastructure::Persistence::Repositories::TodoItemDependencyLinkRepositoryImpl.new
        end

        def default_dependency_specification
          Todos::Domain::Specifications::TodoItemDependencySpecification
        end
      end
    end
  end
end
