require 'rails_helper'

RSpec.describe Todos::Application::Services::DeleteTodoItemService do
  let(:todo_item_repository) { Todos::Infrastructure::Persistence::Repositories::TodoItemRepositoryImpl.new }
  let(:dependency_repository) { Todos::Infrastructure::Persistence::Repositories::TodoItemDependencyLinkRepositoryImpl.new }
  let(:service) { described_class.new(
    todo_item_repository: todo_item_repository,
    dependency_repository: dependency_repository
  ) }
  let(:action) { service.call(item.id) }
  let!(:item) { create(:todo_item_record, title: 'Item to delete', due_date: Date.parse('2025-10-20')) }

  describe '#call' do
    context 'when item exists' do
      it 'deletes the todo item' do
        action
        expect(todo_item_repository.find_with_dependencies(item.id)).to be_nil
      end
    end

    context 'when item has dependencies (depends on other items)' do
      let!(:dependency_item) { create(:todo_item_record, due_date: Date.parse('2025-10-19')) }
      let!(:dependency_link) do
        create(:todo_item_dependency_link_record, todo_item_id: item.id, depends_on_id: dependency_item.id)
      end

      it 'deletes the todo item and removes dependency links' do
        action
        
        expect(todo_item_repository.find_with_dependencies(item.id)).to be_nil
        expect(todo_item_repository.find_with_dependencies(dependency_item.id)).not_to be_nil
      end
    end

    context 'when item has dependents (other items depend on it)' do
      let!(:dependent_item) { create(:todo_item_record, due_date: Date.parse('2025-10-21')) }
      let!(:dependency_link) do
        create(:todo_item_dependency_link_record, todo_item_id: dependent_item.id, depends_on_id: item.id)
      end

      it 'deletes the todo item and removes dependency links' do
        action
        
        expect(todo_item_repository.find_with_dependencies(item.id)).to be_nil
        expect(todo_item_repository.find_with_dependencies(dependent_item.id)).not_to be_nil
        expect(todo_item_repository.find_with_dependencies(dependent_item.id).dependencies).to be_empty
      end
    end

    context 'when item has both dependencies and dependents' do
      let!(:dependency_item) { create(:todo_item_record, due_date: Date.parse('2025-10-19')) }
      let!(:dependent_item) { create(:todo_item_record, due_date: Date.parse('2025-10-21')) }
      let!(:dependency_link) do
        create(:todo_item_dependency_link_record, todo_item_id: item.id, depends_on_id: dependency_item.id)
      end
      let!(:dependent_link) do
        create(:todo_item_dependency_link_record, todo_item_id: dependent_item.id, depends_on_id: item.id)
      end

      it 'deletes the todo item and removes all dependency links' do
        action
        
        expect(todo_item_repository.find_with_dependencies(item.id)).to be_nil
        expect(todo_item_repository.find_with_dependencies(dependency_item.id)).not_to be_nil
        expect(todo_item_repository.find_with_dependencies(dependent_item.id)).not_to be_nil
        expect(todo_item_repository.find_with_dependencies(dependent_item.id).dependencies).to be_empty
      end
    end

    context 'when item does not exist' do
      it 'raises an error' do
        expect { service.call(99999) }.to raise_error(Todos::Domain::Errors::RecordNotFoundError, 'Todo item not found')
      end
    end
  end
end
