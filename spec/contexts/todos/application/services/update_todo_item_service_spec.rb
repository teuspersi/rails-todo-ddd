require 'rails_helper'

RSpec.describe Todos::Application::Services::UpdateTodoItemService do
  let(:service) { described_class.new }
  let(:action) { service.call(to_update_id, params) }

  describe '#call' do
    let(:item) { create(:todo_item_record) }
    let(:to_update_id) { item.id }
    let(:params) { { title: 'Updated Title', due_date: Date.parse('2025-10-21'), completed: true } }

    it 'updates the todo item' do
      action

      expect(item.reload).not_to be_nil
      expect(item.title).to eq('Updated Title')
      expect(item.due_date).to eq(Date.parse('2025-10-21'))
      expect(item.completed).to be(true)
    end
  end
end
