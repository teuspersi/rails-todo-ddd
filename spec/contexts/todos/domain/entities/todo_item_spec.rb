require 'rails_helper'

RSpec.describe Todos::Domain::Entities::TodoItem do
  let(:action) { Todos::Domain::Entities::TodoItem.new(id: 1, title: title, due_date: due_date) }

  context "when title is blank" do
    let(:title) { '' }
    let(:due_date) { Date.today }

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
    let(:item_a) { described_class.new(id: 1, title: 'A', due_date: Date.today) }
    let(:item_b) { described_class.new(id: 2, title: 'B', due_date: Date.today + 1) }
    let(:item_c) { described_class.new(id: 3, title: 'C', due_date: Date.today + 2) }

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
end
