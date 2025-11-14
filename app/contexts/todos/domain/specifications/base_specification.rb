module Todos
  module Domain
    module Specifications
      class BaseSpecification
        def ensure_satisfied!
          raise NotImplementedError
        end
      end
    end
  end
end
