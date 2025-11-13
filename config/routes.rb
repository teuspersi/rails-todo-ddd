Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :todo_items
    end
  end
end