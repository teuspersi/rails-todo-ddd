require 'rails_helper'

RSpec.describe Todos::Application::Services::ListTodoItemsService do
  let(:todo_item_repository) { Todos::Infrastructure::Persistence::Repositories::TodoItemRepositoryImpl.new }
  let(:service) { described_class.new(todo_item_repository: todo_item_repository) }

  describe '#call' do
    context 'when there are no items' do
      it 'returns an empty array' do
        result = service.call
        
        expect(result).to eq([])
      end
    end

    context 'when there are items' do
      let!(:item1) { create(:todo_item_record, title: 'Item 1', due_date: Date.parse('2025-10-22')) }
      let!(:item2) { create(:todo_item_record, title: 'Item 2', due_date: Date.parse('2025-10-20')) }
      let!(:item3) { create(:todo_item_record, title: 'Item 3', due_date: Date.parse('2025-10-21')) }

      it 'returns all items' do
        result = service.call
        
        expect(result.size).to eq(3)
        expect(result).to all(be_a(Todos::Domain::Entities::TodoItem))
      end

      it 'returns items ordered by due_date ascending' do
        result = service.call
        
        expect(result.map(&:id)).to eq([item2.id, item3.id, item1.id])
        expect(result.map(&:due_date)).to eq([
          Date.parse('2025-10-20'),
          Date.parse('2025-10-21'),
          Date.parse('2025-10-22')
        ])
      end

      it 'returns items with dependencies loaded' do
        dependency_item = create(:todo_item_record, due_date: Date.parse('2025-10-19'))
        create(:todo_item_dependency_link_record, todo_item_id: item2.id, depends_on_id: dependency_item.id)
        
        result = service.call
        item_with_dependency = result.find { |item| item.id == item2.id }
        
        expect(item_with_dependency.dependencies.size).to eq(1)
        expect(item_with_dependency.dependencies.first.id).to eq(dependency_item.id)
      end
    end
  end
end
