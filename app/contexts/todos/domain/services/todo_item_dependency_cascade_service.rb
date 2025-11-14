module Todos
  module Domain
    module Services
      class TodoItemDependencyCascadeService
        def initialize(dependency_repository)
          @repository = dependency_repository
          @visited = Set.new
        end

        def collect_all_dependent_ids(item_id)
          collect_recursive(item_id)
        end

        private

        def collect_recursive(item_id)
          return [] if @visited.include?(item_id)
          @visited.add(item_id)

          dependent_ids = @repository.find_dependent_ids(item_id)
          all_ids = dependent_ids.dup

          dependent_ids.each do |dep_id|
            all_ids.concat(collect_recursive(dep_id))
          end

          all_ids
        end
      end
    end
  end
end
