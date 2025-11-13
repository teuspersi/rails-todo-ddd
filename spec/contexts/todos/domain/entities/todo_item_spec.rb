require 'rails_helper'

RSpec.describe Todos::Domain::Entities::TodoItem do
  describe '#valid?' do
    it 'is valid with title and due_date' do
      item = described_class.new(id: 1,title: 'Test', due_date: Date.today)
      
      expect(item.valid?).to be true
    end
  end
end
