module Api
  module V1
    class TodoItemsController < ApplicationController
      before_action :set_todo_item, only: [:show, :update, :destroy]

      rescue_from Todos::Domain::Errors::ValidationError, with: :handle_validation_error
      rescue_from Todos::Domain::Errors::RecordNotFoundError, with: :handle_not_found_error

      def index
        service = Todos::Application::Services::ListTodoItemsService.new
        todo_items = service.call

        render json: Todos::Presentation::Serializers::TodoItemSerializer.collection(todo_items), status: :ok
      end

      def show
        render json: Todos::Presentation::Serializers::TodoItemSerializer.new(@todo_item).as_json, status: :ok
      end

      def create
        service = Todos::Application::Services::CreateTodoItemService.new
        todo_item = service.call(todo_item_params)

        render json: Todos::Presentation::Serializers::TodoItemSerializer.new(todo_item).as_json, status: :created
      end

      def update
        service = Todos::Application::Services::UpdateTodoItemService.new
        todo_item = service.call(@todo_item.id, todo_item_params)

        render json: Todos::Presentation::Serializers::TodoItemSerializer.new(todo_item).as_json, status: :ok
      end

      def destroy
        service = Todos::Application::Services::DeleteTodoItemService.new
        service.call(@todo_item.id)

        head :no_content
      end

      private

      def set_todo_item
        repository = Todos::Infrastructure::Persistence::Repositories::TodoItemRepositoryImpl.new
        @todo_item = repository.find_with_dependencies(params[:id])

        raise Todos::Domain::Errors::RecordNotFoundError, 'Todo item not found' if @todo_item.nil?
      end

      def todo_item_params
        permitted = params.require(:todo_item).permit(:title, :due_date, :completed, dependency_ids: [])
        permitted[:due_date] = Date.parse(permitted[:due_date]) if permitted[:due_date].present?
        permitted
      end

      def handle_validation_error(exception)
        render json: { error: exception.message }, status: :unprocessable_entity
      end

      def handle_not_found_error(exception)
        render json: { error: exception.message }, status: :not_found
      end
    end
  end
end