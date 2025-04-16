module Api
  module V1
    class UsersController < ApplicationController
      before_action :authenticate_user!

      def current
        render json: current_user, status: :ok, serializer: UserSerializer
      end
    end
  end
end
