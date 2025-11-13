module Todos
  module Domain
    module Specifications
      class BaseSpecification
        private

        def ensure_satisfied!
          raise NotImplementedError
        end
      end
    end
  end
end
