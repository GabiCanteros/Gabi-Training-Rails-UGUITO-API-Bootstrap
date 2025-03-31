module Api
  module V1
    class NotesController < ApplicationController
      def index
        render json: notes_filtered, status: :ok, each_serializer: ListNoteSerializer
      end

      def show
        render json: show_note, status: :ok, serializer: FindNoteSerializer
      end

      private

      def notes
        Note.all
      end

      def filtering_params
        param_mapping = { 'type' => 'note_type' }
        mapped_params = {}

        param_mapping.each do |old_param, new_param|
          mapped_params[new_param] = params[old_param] if params[old_param].present?
        end

        mapped_params
      end

      def order
        params[:order] == 'desc' ? 'desc' : 'asc'
      end

      def notes_filtered
        notes.where(filtering_params)
             .order(created_at: order)
             .page(params[:page])
             .per(params[:page_size])
      end

      def show_note
        notes.find(params.require(:id))
      end
    end
  end
end
