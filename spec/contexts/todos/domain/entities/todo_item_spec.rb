require 'rails_helper'

RSpec.describe Todos::Domain::Entities::TodoItem do
  let(:action) { Todos::Domain::Entities::TodoItem.new(id: 1, title: title, due_date: due_date) }

  context "when title is blank" do
    let(:title) { '' }
    let(:due_date) { Date.parse('2025-11-14') }

    it "raises an error" do
      expect { action }.to raise_error(Todos::Domain::Errors::ValidationError)
    end
  end

  context "when due_date is blank" do
    let(:title) { 'Test' }
    let(:due_date) { nil }

    it "raises an error" do
      expect { action }.to raise_error(Todos::Domain::Errors::ValidationError)
    end
  end

  describe "#depends_on?" do
    let(:item_a) { described_class.new(id: 1, title: 'A', due_date: Date.parse('2025-11-14')) }
    let(:item_b) { described_class.new(id: 2, title: 'B', due_date: Date.parse('2025-11-15')) }
    let(:item_c) { described_class.new(id: 3, title: 'C', due_date: Date.parse('2025-11-16')) }

    it 'returns true for direct dependency' do
      item_b.dependencies = [item_a]
      expect(item_b.depends_on?(item_a)).to be true
    end

    it 'returns false when no dependency exists' do
      item_b.dependencies = []
      expect(item_b.depends_on?(item_a)).to be false
    end

    it 'returns true for indirect dependency (transitive)' do
      item_b.dependencies = [item_a]
      item_c.dependencies = [item_b]
      
      expect(item_c.depends_on?(item_a)).to be true
    end
  end

  describe "#update_title" do
    let(:item) { described_class.new(id: 1, title: 'Test', due_date: Date.parse('2025-11-14')) }
    let(:new_title) { 'Updated Title' }

    it 'updates the title' do
      item.update_title(new_title)
      expect(item.title).to eq(new_title)
    end

    context 'when title is blank' do
      let(:new_title) { '' }

      it 'raises an error' do
        expect { item.update_title(new_title) }.to raise_error(Todos::Domain::Errors::ArgumentError)
      end
    end
  end

  describe "#update_due_date" do
    let(:item) { described_class.new(id: 1, title: 'Test', due_date: Date.parse('2025-11-14')) }
    let(:new_due_date) { Date.parse('2025-11-15') }

    it 'updates the due date' do
      item.update_due_date(new_due_date)
      expect(item.due_date).to eq(new_due_date)
    end

    context 'when due date is blank' do
      let(:new_due_date) { nil }

      it 'raises an error' do
        expect { item.update_due_date(new_due_date) }.to raise_error(Todos::Domain::Errors::ArgumentError)
      end
    end
  end

  describe "#update_completed" do
    let(:item) { described_class.new(id: 1, title: 'Test', due_date: Date.parse('2025-11-14')) }
    let(:new_completed) { true }

    it 'updates the completed status' do
      item.update_completed(new_completed)
      expect(item.completed).to eq(new_completed)
    end

    context 'when completed is blank' do
      let(:new_completed) { nil }

      it 'raises an error' do
        expect { item.update_completed(new_completed) }.to raise_error(Todos::Domain::Errors::ArgumentError)
      end
    end
  end
end
