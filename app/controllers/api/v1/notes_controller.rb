module Api
  module V1
    class NotesController < ApplicationController
      before_action :authenticate_user!
      before_action :validate_order_param, :validate_page_params, only: [:index]

      def index
        render json: notes_filtered, status: :ok, each_serializer: IndexNoteSerializer
      end

      def show
        render json: show_note, status: :ok
      end

      private

      def validate_order_param
        return unless order.present? && !%w[asc desc].include?(order)
        render json: { error: I18n.t('errors.invalid_order_param') },
               status: :unprocessable_entity
      end

      def validate_page_params
        return render_page_error unless params[:page].present? && valid_number?(params[:page])

        render_page_error unless params[:page_size].present? && valid_number?(params[:page_size])
      end

      def render_page_error
        render json: { error: I18n.t('errors.invalid_page_param') },
               status: :unprocessable_entity
      end

      def valid_number?(value)
        value.to_i.positive?
      end

      def notes_filtered
        notes.where(filtering_params)
             .order(created_at: order)
             .page(params[:page])
             .per(params[:page_size])
      end

      def notes
        current_user.notes
      end

      def filtering_params
        params_transformed.permit(%i[note_type title])
      end

      def params_transformed
        param_mapping = { 'type' => 'note_type' }
        params.transform_keys! { |key| param_mapping[key] || key }
      end

      def order
        @order ||= params[:order] || 'asc'
      end

      def show_note
        notes.find(params.require(:id))
      end
    end
  end
end

