require 'rails_helper'

describe Api::V1::NotesController, type: :controller do
  describe 'GET #index' do
    let(:user_notes) { create_list(:note, 5, user: user) }

    context 'when there is a user logged in' do
      include_context 'with authenticated user'

      let!(:expected) do
        ActiveModel::Serializer::CollectionSerializer.new(notes_expected,
                                                          serializer: IndexNoteSerializer).to_json
      end
      let(:notes_expected) { user_notes }

      context 'when fetching all the notes for user' do
        let(:notes_expected) { user_notes }

        before { get :index, params: { page: 1, page_size: 50 } }

        it 'responds with the expected notes json' do
          expect(response_body.to_json).to eq(expected)
        end

        it 'responds with 200 status' do
          expect(response).to have_http_status(:ok)
        end
      end

      context 'when fetching notes with page and page size params' do
        let(:page)            { 1 }
        let(:page_size)       { 2 }
        let(:notes_expected) { user_notes.first(2) }

        before { get :index, params: { page: page, page_size: page_size } }

        it 'responds with the expected notes' do
          expect(response_body.to_json).to eq(expected)
        end

        it 'responds with 200 status' do
          expect(response).to have_http_status(:ok)
        end
      end

      context 'when fetching notes using filters' do
        let(:type) { 'review' }

        let!(:notes_custom) { create_list(:note, 2, user: user, note_type: type) }
        let(:notes_expected) { notes_custom }

        before { get :index, params: { page: 1, page_size: 50, type: type } }

        it 'responds with expected notes' do
          expect(response_body.to_json).to eq(expected)
        end

        it 'responds with 200 status' do
          expect(response).to have_http_status(:ok)
        end
      end

      context 'when order is valid' do
        let(:order) { 'asc' }

        let(:user_notes_order) { user_notes.sort_by { |i_note| i_note[:created_at] } }

        let(:notes_expected) { user_notes_order }

        before { get :index, params: { page: 1, page_size: 50, order: order } }

        it 'responds with 200 status' do
          expect(response).to have_http_status(:ok)
        end

        it 'responds with expected notes' do
          expect(response_body.to_json).to eq(expected)
        end
      end

      context 'when order is invalid' do
        let(:order) { 'hola' }

        before { get :index, params: { page: 1, page_size: 10, order: order } }

        it 'responds with Unprocessable Entity status' do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'responds with a correct error message' do
          expect(response.body).to include('El parámetro de orden es inválido. Debe ser asc o desc.')
        end
      end

      context 'when page is invalid' do
        let(:page) { 0 }
        let(:page_size) { 10 }

        before { get :index, params: { page: page, page_size: page_size } }

        it 'responds with Unprocessable Entity status' do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'responds with an error message for invalid page' do
          expect(response.body).to include('Página o tamaño de página inválidos o no presentes. Usa un número entero positivo.')
        end
      end

      context 'when page_size is invalid' do
        let(:page) { 1 }
        let(:page_size) { 'a' }

        before { get :index, params: { page: page, page_size: page_size } }

        it 'responds with Unprocessable Entity status' do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'responds with an error message for invalid page_size' do
          expect(response.body).to include('Página o tamaño de página inválidos o no presentes. Usa un número entero positivo.')
        end
      end

      context 'when page is missing' do
        let(:page_size) { 10 }

        before { get :index, params: { page_size: page_size } }

        it 'responds with Unprocessable Entity status' do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'responds with an error message for invalid page_size' do
          expect(response.body).to include('Página o tamaño de página inválidos o no presentes. Usa un número entero positivo.')
        end
      end

      context 'when page_size is missing' do
        let(:page) { 1 }

        before { get :index, params: { page: page } }

        it 'responds with Unprocessable Entity status' do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'responds with an error message for invalid page_size' do
          expect(response.body).to include('Página o tamaño de página inválidos o no presentes. Usa un número entero positivo.')
        end
      end
    end

    context 'when there is not a user logged in' do
      context 'when fetching all the notes for user' do
        before { get :index, params: { page: 1, page_size: 50 } }

        it_behaves_like 'unauthorized'
      end
    end
  end

  describe 'GET #show' do
    context 'when there is a user logged in' do
      include_context 'with authenticated user'

      let(:expected) { NoteSerializer.new(note, root: false).to_json }

      context 'when fetching a valid note' do
        let(:note) { create(:note, user: user) }

        before { get :show, params: { id: note.id } }

        it 'responds with the note json' do
          expect(response.body).to eq(expected)
        end

        it 'responds with 200 status' do
          expect(response).to have_http_status(:ok)
        end
      end

      context 'when fetching a invalid note' do
        before { get :show, params: { id: Faker::Number.number } }

        it 'responds with 404 status' do
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context 'when there is not a user logged in' do
      context 'when fetching an note' do
        before { get :show, params: { id: Faker::Number.number } }

        it_behaves_like 'unauthorized'
      end
    end
  end
end
