FactoryBot.define do
  factory :todo_item_dependency_record, class: 'Todos::Infrastructure::Persistence::ActiveRecord::TodoItemDependencyRecord' do
    association :todo_item_record
    association :depends_on_record, factory: :todo_item_record
  end
end
