require 'rails_helper'

RSpec.describe Todos::Domain::Entities::TodoItemDependency do
  let(:action) { described_class.new(id: 1, todo_item_id: todo_item_id, depends_on_id: depends_on_id) }

  context 'when todo_item_id is blank' do
    let(:todo_item_id) { nil }
    let(:depends_on_id) { 1 }

    it 'raises an error' do
      expect { action }.to raise_error(Todos::Domain::Errors::ValidationError)
    end
  end

  context 'when depends_on_id is blank' do
    let(:todo_item_id) { 1 }
    let(:depends_on_id) { nil }

    it 'raises an error' do
      expect { action }.to raise_error(Todos::Domain::Errors::ValidationError)
    end
  end

  context 'when todo_item_id equals depends_on_id' do
    let(:todo_item_id) { 1 }
    let(:depends_on_id) { 1 }

    it 'raises an error' do
      expect { action }.to raise_error(Todos::Domain::Errors::ValidationError)
    end
  end
end
