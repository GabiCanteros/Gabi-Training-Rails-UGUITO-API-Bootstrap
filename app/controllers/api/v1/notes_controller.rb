module Api
  module V1
    class NotesController < ApplicationController
      before_action :authenticate_user!
      before_action :validate_order_param, :validate_page_params, only: [:index]
      before_action :transform_params, :validate_required_params, :validate_note_type,
                    :validate_review_word_count, only: [:create]

      def index
        render json: notes_filtered, status: :ok, each_serializer: IndexNoteSerializer
      end

      def show
        render json: show_note, status: :ok
      end

      def create
        Note.create!(note_params_with_references)
        render json: { message: 'Nota creada con éxito.' }, status: :created
      end

      private

      def transform_params
        return unless params[:note] && params[:note][:type]
        params[:note][:note_type] = params[:note].delete(:type)
      end

      def validate_required_params
        required_params = %i[title note_type content]
        missing_params = required_params.select { |param| params[:note][param].blank? }

        return unless missing_params.any?
        render json:
        { error:
        I18n.t('activerecord.errors.controllers.api.v1.notes_controller.params_missing') },
               status: :bad_request
      end

      def validate_note_type
        return if Note.note_types.keys.include?(params[:note][:note_type])
        render json: { error:
        I18n.t('activerecord.errors.controllers.api.v1.notes_controller.invalid_note_type') },
               status: :unprocessable_entity
      end

      def validate_review_word_count
        unless word_count > current_user.utility.max_word_valid_review &&
               params[:note][:note_type] == 'review'
          return
        end
        render json: { error:
        I18n.t('activerecord.errors.controllers.api.v1.notes_controller.review_word_count',
               max_word_limit: current_user.utility.max_word_valid_review) },
               status: :unprocessable_entity
      end

      def word_count
        params[:note][:content].split(/\s+/).size
      end

      def note_params_with_references
        note_params.merge(user_id: current_user.id)
      end

      def note_params
        params.require(:note).permit(:note_type, :title, :content, :user_id)
      end

      def remake_error_message(message)
        message.record.errors.full_messages.map { |msg| msg.split(' ', 2).last }.join(', ')
      end

      def validate_order_param
        return unless order.present? && !%w[asc desc].include?(order)
        render json: { error:
        I18n.t('activerecord.errors.controllers.api.v1.notes_controller.invalid_order_param') },
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
        I18n.t('activerecord.errors.controllers.api.v1.notes_controller.invalid_page_param') },
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

      def params_transformed
        param_mapping = { 'type' => 'note_type' }
        params.transform_keys! { |key| param_mapping[key] || key }
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
