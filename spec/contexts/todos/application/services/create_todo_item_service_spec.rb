require 'rails_helper'

RSpec.describe Todos::Application::Services::CreateTodoItemService do
  let(:service) { described_class.new }
  let(:action) { service.call(params) }

  describe '#call' do
    let(:params) { { title: 'Test', due_date: Date.today } }

    it 'creates a todo item' do
      result = action

      expect(result).not_to be_nil
      expect(result.title).to eq('Test')
      expect(result.due_date).to eq(Date.today)
    end

    context 'with dependencies' do
      let(:dependency) { create(:todo_item_record, due_date: Date.today) }
      let(:params) { { title: 'Task B', due_date: Date.today + 1, dependency_ids: [dependency.id] } }

      it 'creates with dependencies' do
        result = action
      
        expect(result.dependencies.size).to eq(1)
      end
    end
  end
end
