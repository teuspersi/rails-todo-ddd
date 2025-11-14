require 'rails_helper'

RSpec.describe Todos::Application::Services::CreateTodoItemService do
  let(:service) { described_class.new }

  describe '#call' do
    it 'creates a todo item' do
      result = service.call(title: 'Test', due_date: Date.parse('2025-11-14'))

      expect(result).not_to be_nil
      expect(result.title).to eq('Test')
      expect(result.due_date).to eq(Date.parse('2025-11-14'))
    end

    context 'with dependencies' do
      let(:dependency) { create(:todo_item_record, due_date: Date.parse('2025-11-14')) }

      it 'creates with dependencies' do
        result = service.call(title: 'Task B', due_date: Date.parse('2025-11-15'), dependency_ids: [dependency.id])
      
        expect(result.dependencies.size).to eq(1)
      end
    end

    context 'with invalid dependency (due_date violation)' do
      let(:dependency) { create(:todo_item_record, due_date: Date.parse('2025-11-15')) }

      it 'raises an error' do
        expect {
          service.call(title: 'Task B', due_date: Date.parse('2025-11-14'), dependency_ids: [dependency.id])
        }.to raise_error(Todos::Domain::Errors::ValidationError, "Due date must be after dependency's due date")
      end
    end
  end
end
