require 'rails_helper'

RSpec.describe Todos::Domain::Services::TodoItemDependencyCascadeService do
  let(:repository) { double('repository') }
  let(:service) { described_class.new(repository) }

  describe '#collect_all_dependent_ids' do
    context 'when item has no dependents' do
      it 'returns empty array' do
        allow(repository).to receive(:find_dependent_ids).with(1).and_return([])

        result = service.collect_all_dependent_ids(1)

        expect(result).to eq([])
      end
    end

    context 'when item has one level of dependents' do
      it 'returns all dependent ids' do
        allow(repository).to receive(:find_dependent_ids).with(1).and_return([2, 3])
        allow(repository).to receive(:find_dependent_ids).with(2).and_return([])
        allow(repository).to receive(:find_dependent_ids).with(3).and_return([])

        result = service.collect_all_dependent_ids(1)

        expect(result).to contain_exactly(2, 3)
      end
    end

    context 'when item has nested dependents (A -> B -> C)' do
      it 'returns all dependent ids recursively' do
        allow(repository).to receive(:find_dependent_ids).with(1).and_return([2])
        allow(repository).to receive(:find_dependent_ids).with(2).and_return([3])
        allow(repository).to receive(:find_dependent_ids).with(3).and_return([])

        result = service.collect_all_dependent_ids(1)

        expect(result).to contain_exactly(2, 3)
      end
    end

    context 'when item has multiple branches (A -> B, A -> C, B -> D)' do
      it 'returns all dependent ids from all branches' do
        allow(repository).to receive(:find_dependent_ids).with(1).and_return([2, 3])
        allow(repository).to receive(:find_dependent_ids).with(2).and_return([4])
        allow(repository).to receive(:find_dependent_ids).with(3).and_return([])
        allow(repository).to receive(:find_dependent_ids).with(4).and_return([])

        result = service.collect_all_dependent_ids(1)

        expect(result).to contain_exactly(2, 3, 4)
      end
    end

    context 'when there is a circular dependency (should not happen but handles it)' do
      it 'prevents infinite loop with visited tracking' do
        allow(repository).to receive(:find_dependent_ids).with(1).and_return([2])
        allow(repository).to receive(:find_dependent_ids).with(2).and_return([1])

        result = service.collect_all_dependent_ids(1)

        # returns both 2 and 1 (circular), but prevents infinite loop
        expect(result).to contain_exactly(2, 1)
      end
    end
  end
end
