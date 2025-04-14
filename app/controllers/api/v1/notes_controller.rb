module Api
  module V1
    class NotesController < ApplicationController
      before_action :authenticate_user!
      before_action :validate_order_param, :validate_page_params, only: [:index]
      rescue_from ActiveRecord::RecordInvalid, with: :handle_record_invalid
      rescue_from ActionController::ParameterMissing, with: :handle_parameter_missing
      rescue_from ArgumentError, with: :handle_argument_error

      def index
        render json: notes_filtered, status: :ok, each_serializer: IndexNoteSerializer
      end

      def show
        render json: show_note, status: :ok
      end

      def create
        params_transformed
        current_user.notes.create!(note_params)
        render json: { message:
              I18n.t('controllers.errors.api.v1.notes_controller.success_note_create') },
               status: :created
      end

      private

      def handle_record_invalid(exception)
        error_messages = remake_error_message(exception)
        render json: { error: error_messages }, status: :unprocessable_entity
      end

      def remake_error_message(message)
        message.record.errors.full_messages.map { |msg| msg.split(' ', 2).last }.join(', ')
      end

      def handle_parameter_missing(_exception)
        render json: { error:
              I18n.t('controllers.errors.api.v1.notes_controller.params_missing') },
               status: :bad_request
      end

      def handle_argument_error(_exception)
        render json: { error:
              I18n.t('controllers.errors.api.v1.notes_controller.invalid_note_type') },
               status: :unprocessable_entity
      end

      def params_transformed
        param_mapping = { 'type' => 'note_type' }
        params.deep_transform_keys! do |key|
          param_mapping[key.to_s] || key
        end
      end

      def note_params
        params.require(:note).require(%i[title note_type content])
        params.require(:note).permit(%i[title note_type content])
      end

      def validate_order_param
        return unless order.present? && !%w[asc desc].include?(order)
        render json: { error:
        I18n.t('controllers.errors.api.v1.notes_controller.invalid_order_param') },
               status: :unprocessable_entity
      end

      def order
        @order ||= params[:order] || 'asc'
      end

      def validate_page_params
        return render_page_error unless params[:page].present? && valid_number?(params[:page])
        render_page_error unless params[:page_size].present? && valid_number?(params[:page_size])
      end

      def render_page_error
        render json: { error:
        I18n.t('controllers.errors.api.v1.notes_controller.invalid_page_param') },
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

      def filtering_params
        params_transformed.permit(%i[note_type title])
      end

      def show_note
        notes.find(params.require(:id))
      end

      def notes
        current_user.notes
      end
    end
  end
end
