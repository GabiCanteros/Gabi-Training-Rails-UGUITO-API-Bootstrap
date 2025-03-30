module Api
  module V1
    class UsersController < ApplicationController
      before_action :authenticate_user! #comentar esta linea

      def current
        render json: current_user, status: :ok, serializer: UserSerializer #reemplazar User.find(1) por current_user
      end
    end
  end
end
