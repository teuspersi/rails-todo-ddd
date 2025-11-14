require 'rails_helper'

RSpec.describe Todos::Domain::Specifications::TodoItemDependencySpecification do
  let(:action) { described_class.new(item_a, item_b).ensure_satisfied! }

  let(:item_a) do
    Todos::Domain::Entities::TodoItem.new(
      id: 1,
      title: 'Task A',
      due_date: Date.parse('2025-11-14')
    )
  end

  let(:item_b) do
    Todos::Domain::Entities::TodoItem.new(
      id: 2,
      title: 'Task B',
      due_date: Date.parse('2025-11-13')
    )
  end

  context 'when dependency does not exist' do
    let(:item_b) { nil }
    
    it 'raises an error' do
      expect { action }.to raise_error(Todos::Domain::Errors::ValidationError, 'Dependency not found')
    end
  end

  context 'when item depends on itself' do
    let(:item_b) { item_a }
    
    it 'raises an error' do
      expect { action }.to raise_error(Todos::Domain::Errors::ValidationError, 'Item cannot depend on itself')
    end
  end

  context 'when would create circular dependency' do
    before do
      item_b.dependencies = [item_a]
    end

    it 'raises an error' do
      expect { action }.to raise_error(Todos::Domain::Errors::ValidationError, 'Cannot create circular dependency')
    end
  end

  context 'when would create circular dependency at deeper levels' do
    let(:item_c) do
      Todos::Domain::Entities::TodoItem.new(
        id: 3,
        title: 'Task C',
        due_date: Date.parse('2025-11-12')
      )
    end

    before do
      item_b.dependencies = [item_c]
      item_a.dependencies = [item_b]
    end

    let(:action) { described_class.new(item_c, item_a).ensure_satisfied! }

    it 'raises an error detecting the deep circular dependency' do
      expect { action }.to raise_error(Todos::Domain::Errors::ValidationError, 'Cannot create circular dependency')
    end
  end

  context 'when due_date is equal to dependency due_date' do
    let(:item_b) { Todos::Domain::Entities::TodoItem.new(id: 2, title: 'Task B', due_date: Date.parse('2025-11-14')) }
    
    it 'raises an error' do
      expect { action }.to raise_error(Todos::Domain::Errors::ValidationError, "Due date must be after dependency's due date")
    end
  end

  context 'when due_date is before dependency due_date' do
    let(:item_b) { Todos::Domain::Entities::TodoItem.new(id: 2, title: 'Task B', due_date: Date.parse('2025-11-15')) }
    
    it 'raises an error' do
      expect { action }.to raise_error(Todos::Domain::Errors::ValidationError, "Due date must be after dependency's due date")
    end
  end

  context 'when all conditions are met' do
    it 'does not raise an error' do
      expect { action }.not_to raise_error
    end
  end
end
