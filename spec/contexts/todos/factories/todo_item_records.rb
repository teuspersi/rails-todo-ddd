FactoryBot.define do
  factory :todo_item_record, class: 'Todos::Infrastructure::Persistence::ActiveRecord::TodoItemRecord' do
    sequence(:title) { |n| "Todo Item #{n}" }
    due_date { Date.today + rand(1..30).days }
  end
end