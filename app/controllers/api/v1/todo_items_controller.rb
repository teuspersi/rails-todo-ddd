module Api
  module V1
    class TodoItemsController < ApplicationController
      def index
        render json: { message: "hello world" }
      end
    end
  end
end