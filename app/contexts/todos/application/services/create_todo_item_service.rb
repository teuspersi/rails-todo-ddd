module Todos
  module Application
    module Services
      class CreateTodoItemService
        def initialize(
          todo_item_repository: default_todo_item_repository,
          dependency_repository: default_dependency_repository,
          specification: default_specification
        )
          @todo_item_repository = todo_item_repository
          @dependency_repository = dependency_repository
          @specification = specification
        end

        def call(params)
          ::ActiveRecord::Base.transaction do
            todo_item = create_todo_item(params)
            create_dependencies(todo_item, params[:dependency_ids]) if params[:dependency_ids].present?
            
            @todo_item_repository.find_with_dependencies(todo_item.id)
          end
        end

        private

        def create_todo_item(params)
          todo_item = Todos::Domain::Entities::TodoItem.new(
            id: nil,
            title: params[:title],
            due_date: params[:due_date]
          )
          @todo_item_repository.save(todo_item)
        end

        def create_dependencies(todo_item, dependency_ids)
          Array(dependency_ids).each do |dependency_id|
            dependency = @todo_item_repository.find_with_dependencies(dependency_id)

            @specification.new(todo_item, dependency).ensure_satisfied!

            @dependency_repository.create(todo_item.id, dependency.id)
          end
        end

        def default_todo_item_repository
          Todos::Infrastructure::Persistence::Repositories::TodoItemRepositoryImpl.new
        end

        def default_dependency_repository
          Todos::Infrastructure::Persistence::Repositories::TodoItemDependencyRepositoryImpl.new
        end

        def default_specification
          Todos::Domain::Specifications::TodoItemDependencySpecification
        end
      end
    end
  end
end
  