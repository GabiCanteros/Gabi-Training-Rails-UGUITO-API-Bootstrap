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
      let(:page) { 1 }
      let(:page_size) { 50 }

      context 'when page and page_size are params' do
        before { get :index, params: { page: page, page_size: page_size } }

        context 'when fetching all the notes for user' do
          it_behaves_like 'good responses'
        end

        context 'when page is invalid' do
          let(:page) { 0 }
          let(:page_size) { 10 }

          it 'responds with Unprocessable Entity status' do
            expect(response).to have_http_status(:unprocessable_entity)
          end

          it 'responds with an error message for invalid page' do
            expect(response.body).to include(I18n.t('errors.invalid_page_param'))
          end
        end

        context 'when page_size is invalid' do
          let(:page) { 1 }
          let(:page_size) { Faker::Lorem.word }

          it 'responds with Unprocessable Entity status' do
            expect(response).to have_http_status(:unprocessable_entity)
          end

          it 'responds with an error message for invalid page_size' do
            expect(response.body).to include(I18n.t('errors.invalid_page_param'))
          end
        end

        context 'when fetching notes and page_size = 2 ' do
          let(:page_size) { 2 }
          let(:total_pages) { user_notes.size.div(page_size) }
          let(:page) { (1..total_pages).to_a.sample }
          let(:size_expected) { page_size % page == 0 ? page_size : (notes_expected.size % page_size) }

          it 'responds with the expected first note' do
            expect(response_body.first).to eq(JSON.parse(expected)[page * page_size - page_size])
          end

          it 'responds with the expected page size' do
            expect(response_body.size).to eq(size_expected)
          end

          it 'responds with 200 status' do
            expect(response).to have_http_status(:ok)
          end
        end
      end

      context 'when page, page_size and type are params' do
        before { get :index, params: { page: page, page_size: page_size, type: type } }

        context 'when fetching notes using filters' do
          let(:type) { 'review' }
          let(:page) { 1 }
          let(:page_size) { 50 }
          let!(:notes_custom) { create_list(:note, 2, user: user, note_type: type) }
          let(:notes_expected) { notes_custom }

          it_behaves_like 'good responses'
        end
      end

      context 'when page, page_size and order are params' do
        before { get :index, params: { page: page, page_size: page_size, order: order } }

        let(:page) { 1 }
        let(:page_size) { 50 }

        context 'when order is valid' do
          let(:user_notes_order_asc) { user_notes.sort_by { |i_note| i_note[:created_at] } }

          context 'when is asc' do
            let(:order) { 'asc' }
            let(:notes_expected) { user_notes_order_asc }

            it_behaves_like 'good responses'
          end

          context 'when is desc' do
            let(:order) { 'desc' }
            let(:notes_expected) { user_notes_order_asc.reverse }

            it_behaves_like 'good responses'
          end
        end

        context 'when order is invalid' do
          let(:order) { Faker::Lorem.word }

          it 'responds with Unprocessable Entity status' do
            expect(response).to have_http_status(:unprocessable_entity)
          end

          it 'responds with a correct error message' do
            expect(response.body).to include(I18n.t('errors.invalid_order_param'))
          end
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

        it_behaves_like 'good responses'
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
