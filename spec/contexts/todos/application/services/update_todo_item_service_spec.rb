require 'rails_helper'

RSpec.describe Todos::Application::Services::UpdateTodoItemService do
  let(:service) { described_class.new }
  let(:action) { service.call(to_update_id, params) }

  describe '#call' do
    let(:item) { create(:todo_item_record, due_date: Date.parse('2025-10-20')) }
    let(:to_update_id) { item.id }
    let(:params) { { title: 'Updated Title', due_date: Date.parse('2025-10-21'), completed: true } }

    it 'updates the todo item' do
      action

      expect(item.reload).not_to be_nil
      expect(item.title).to eq('Updated Title')
      expect(item.due_date).to eq(Date.parse('2025-10-21'))
      expect(item.completed).to be(true)
    end

    context "when dependency_ids are provided" do
      let!(:dependency_item) { create(:todo_item_record, due_date: Date.parse('2025-10-19')) }
      let(:params) { { title: 'Updated Title', due_date: Date.parse('2025-10-21'), completed: true, dependency_ids: [dependency_item.id] } }

      it 'updates the todo item dependencies' do
        action

        expect(item.reload.dependency_records.size).to eq(1)
      end

      context "when new due_date is invalid according to new dependency due_date" do
        let!(:dependency_item) { create(:todo_item_record, due_date: Date.parse('2025-10-21')) }

        it 'raises an error' do
          expect { action }.to raise_error(Todos::Domain::Errors::ValidationError)
        end
      end
    end

    context "when new due_date is invalid according to existing dependency due_date" do
      let(:params) { { due_date: Date.parse('2025-10-19') } }
      let!(:dependency_item) { create(:todo_item_record, due_date: Date.parse('2025-10-20')) }
      let!(:dependency) { create(:todo_item_dependency_link_record, todo_item_record: item, depends_on_record: dependency_item) }

      it 'raises an error' do
        expect { action }.to raise_error(Todos::Domain::Errors::ValidationError)
      end
    end
  end
end
