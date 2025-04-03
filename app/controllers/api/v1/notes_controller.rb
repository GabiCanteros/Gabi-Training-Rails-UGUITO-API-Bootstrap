module Api
  module V1
    class NotesController < ApplicationController
      before_action :validate_order_param, only: [:index]
      before_action :validate_page_params, only: [:index]

      def index
        render json: notes_filtered, status: :ok, each_serializer: IndexNoteSerializer
      end

      def show
        render json: show_note, status: :ok
      end

      private

      def validate_order_param
        return unless params[:order].present? && !%w[asc desc].include?(params[:order])
        render json: { error: 'Invalid order parameter. It must be either "asc" or "desc".' },
               status: :unprocessable_entity
      end
      def validate_page_params
        if params[:page].present? && !valid_number?(params[:page])
          render json: { error: 'Page must be a positive integer.' }, status: :unprocessable_entity
          return
        end
    
        if params[:page_size].present? && !valid_number?(params[:page_size])
          render json: { error: 'Page size must be a positive integer.' }, status: :unprocessable_entity
          return
        end
      end

      def valid_number?(value)
        value.to_i > 0
      end

      def notes_filtered
        notes.where(filtering_params)
             .order(created_at: order)
             .page(params[:page])
             .per(params[:page_size])
      end

      def notes
        Note.all
      end

      def filtering_params
        params_transformed.permit(%i[note_type title])
      end

      def params_transformed
        params.require(%i[page page_size])
        param_mapping = { 'type' => 'note_type' }
        params.transform_keys! { |key| param_mapping[key] || key }
      end

      def order
        params[:order] == 'desc' ? 'desc' : 'asc'
      end

      def show_note
        notes.find(params.require(:id))
      end

      
    end
  end
end
