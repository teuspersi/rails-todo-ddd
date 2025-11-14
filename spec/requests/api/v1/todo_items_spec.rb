require 'rails_helper'

RSpec.describe 'Api::V1::TodoItems', type: :request do
  let(:headers) { { 'Content-Type' => 'application/json' } }

  describe 'GET /api/v1/todo_items' do
    context 'when there are no items' do
      it 'returns an empty array' do
        get '/api/v1/todo_items', headers: headers

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq([])
      end
    end

    context 'when there are items' do
      let!(:item1) { create(:todo_item_record, title: 'Item 1', due_date: Date.parse('2025-10-22')) }
      let!(:item2) { create(:todo_item_record, title: 'Item 2', due_date: Date.parse('2025-10-20')) }

      it 'returns all items ordered by due_date' do
        get '/api/v1/todo_items', headers: headers

        expect(response).to have_http_status(:ok)
        
        json = JSON.parse(response.body)
        expect(json.size).to eq(2)
        expect(json.first['id']).to eq(item2.id)
        expect(json.first['title']).to eq('Item 2')
        expect(json.last['id']).to eq(item1.id)
      end

      it 'includes dependencies and dependents' do
        dependency = create(:todo_item_record, due_date: Date.parse('2025-10-19'))
        create(:todo_item_dependency_link_record, todo_item_id: item2.id, depends_on_id: dependency.id)

        get '/api/v1/todo_items', headers: headers

        json = JSON.parse(response.body)
        item_with_dep = json.find { |i| i['id'] == item2.id }
        
        expect(item_with_dep['dependencies'].size).to eq(1)
        expect(item_with_dep['dependencies'].first['id']).to eq(dependency.id)
      end
    end
  end

  describe 'GET /api/v1/todo_items/:id' do
    let!(:item) { create(:todo_item_record, title: 'Test Item', due_date: Date.parse('2025-10-20')) }

    context 'when item exists' do
      it 'returns the item' do
        get "/api/v1/todo_items/#{item.id}", headers: headers

        expect(response).to have_http_status(:ok)
        
        json = JSON.parse(response.body)
        expect(json['id']).to eq(item.id)
        expect(json['title']).to eq('Test Item')
        expect(json['due_date']).to eq('2025-10-20')
      end
    end

    context 'when item does not exist' do
      it 'returns not found' do
        get '/api/v1/todo_items/99999', headers: headers

        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['error']).to eq('Todo item not found')
      end
    end
  end

  describe 'POST /api/v1/todo_items' do
    let(:valid_params) do
      {
        todo_item: {
          title: 'New Item',
          due_date: '2025-10-20',
          completed: false
        }
      }
    end

    context 'with valid params' do
      it 'creates a new item' do
        post '/api/v1/todo_items', params: valid_params.to_json, headers: headers

        expect(response).to have_http_status(:created)
        
        json = JSON.parse(response.body)
        expect(json['title']).to eq('New Item')
        expect(json['due_date']).to eq('2025-10-20')
        expect(json['id']).to be_present
      end
    end

    context 'with dependencies' do
      let!(:dependency) { create(:todo_item_record, due_date: Date.parse('2025-10-19')) }
      let(:params_with_deps) do
        {
          todo_item: {
            title: 'New Item',
            due_date: '2025-10-20',
            completed: false,
            dependency_ids: [dependency.id]
          }
        }
      end

      it 'creates item with dependencies' do
        post '/api/v1/todo_items', params: params_with_deps.to_json, headers: headers

        expect(response).to have_http_status(:created)
        
        json = JSON.parse(response.body)
        expect(json['dependencies'].size).to eq(1)
        expect(json['dependencies'].first['id']).to eq(dependency.id)
      end
    end

    context 'with invalid params' do
      let(:invalid_params) do
        {
          todo_item: {
            title: '',
            due_date: '2025-10-20'
          }
        }
      end

      it 'returns unprocessable entity' do
        post '/api/v1/todo_items', params: invalid_params.to_json, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['error']).to be_present
      end
    end

    context 'with invalid dependency (due_date violation)' do
      let!(:dependency) { create(:todo_item_record, due_date: Date.parse('2025-10-21')) }
      let(:params_with_invalid_deps) do
        {
          todo_item: {
            title: 'New Item',
            due_date: '2025-10-20',
            dependency_ids: [dependency.id]
          }
        }
      end

      it 'returns unprocessable entity' do
        post '/api/v1/todo_items', params: params_with_invalid_deps.to_json, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['error']).to include("Due date must be after dependency's due date")
      end
    end
  end

  describe 'PUT /api/v1/todo_items/:id' do
    let!(:item) { create(:todo_item_record, title: 'Old Title', due_date: Date.parse('2025-10-20')) }

    context 'with valid params' do
      let(:update_params) do
        {
          todo_item: {
            title: 'Updated Title',
            completed: true
          }
        }
      end

      it 'updates the item' do
        put "/api/v1/todo_items/#{item.id}", params: update_params.to_json, headers: headers

        expect(response).to have_http_status(:ok)
        
        json = JSON.parse(response.body)
        expect(json['title']).to eq('Updated Title')
        expect(json['completed']).to be(true)
      end
    end

    context 'with cascading due_date update' do
      let!(:dependent) { create(:todo_item_record, due_date: Date.parse('2025-10-21')) }
      let!(:dependency_link) do
        create(:todo_item_dependency_link_record, todo_item_id: dependent.id, depends_on_id: item.id)
      end
      let(:update_params) do
        {
          todo_item: {
            due_date: '2025-10-22'
          }
        }
      end

      it 'cascades due_date to dependents' do
        put "/api/v1/todo_items/#{item.id}", params: update_params.to_json, headers: headers

        expect(response).to have_http_status(:ok)
        
        expect(dependent.reload.due_date).to eq(Date.parse('2025-10-23'))
      end
    end

    context 'when item does not exist' do
      it 'returns not found' do
        put '/api/v1/todo_items/99999', params: { todo_item: { title: 'Test' } }.to_json, headers: headers

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'DELETE /api/v1/todo_items/:id' do
    let!(:item) { create(:todo_item_record, title: 'Item to delete', due_date: Date.parse('2025-10-20')) }
    let(:repository) { Todos::Infrastructure::Persistence::Repositories::TodoItemRepositoryImpl.new }

    context 'when item exists' do
      it 'deletes the item' do
        delete "/api/v1/todo_items/#{item.id}", headers: headers

        expect(response).to have_http_status(:no_content)
        expect(repository.find_with_dependencies(item.id)).to be_nil
      end
    end

    context 'when item has dependencies' do
      let!(:dependency) { create(:todo_item_record, due_date: Date.parse('2025-10-19')) }
      let!(:dependency_link) do
        create(:todo_item_dependency_link_record, todo_item_id: item.id, depends_on_id: dependency.id)
      end

      it 'deletes the item and removes dependency links' do
        delete "/api/v1/todo_items/#{item.id}", headers: headers

        expect(response).to have_http_status(:no_content)
        expect(repository.find_with_dependencies(item.id)).to be_nil
        expect(repository.find_with_dependencies(dependency.id)).not_to be_nil
      end
    end

    context 'when item does not exist' do
      it 'returns not found' do
        delete '/api/v1/todo_items/99999', headers: headers

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
