FactoryBot.define do
  factory :todo_item_dependency_link_record, class: 'Todos::Infrastructure::Persistence::ActiveRecord::TodoItemDependencyLinkRecord' do
    association :todo_item_record
    association :depends_on_record, factory: :todo_item_record
  end
end
