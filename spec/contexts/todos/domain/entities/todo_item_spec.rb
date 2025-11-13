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
end
