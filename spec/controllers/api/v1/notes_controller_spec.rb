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


      context 'when page and page_size are params' do
        before { get :index, params: { page: page, page_size: page_size } }

        context 'when fetching all the notes for user' do
          let(:page) { 1 }
          let(:page_size) { 50 }
          it_behaves_like 'success index notes responses'
        end

        context 'when page is invalid' do
          let(:page) { 0 }
          let(:page_size) { 10 }

          it 'responds with Unprocessable Entity status' do
            expect(response).to have_http_status(:unprocessable_entity)
          end

          it 'responds with an error message for invalid page' do
            expect(response.body).to include(I18n.t('controllers.errors.api.v1.notes_controller.invalid_page_param'))
          end
        end

        context 'when page_size is invalid' do
          let(:page) { 1 }
          let(:page_size) { Faker::Lorem.word }

          it 'responds with Unprocessable Entity status' do
            expect(response).to have_http_status(:unprocessable_entity)
          end

          it 'responds with an error message for invalid page_size' do
            expect(response.body).to include(I18n.t('controllers.errors.api.v1.notes_controller.invalid_page_param'))
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

          it_behaves_like 'success index notes responses'
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

            it_behaves_like 'success index notes responses'
          end

          context 'when is desc' do
            let(:order) { 'desc' }
            let(:notes_expected) { user_notes_order_asc.reverse }

            it_behaves_like 'success index notes responses'
          end
        end

        context 'when order is invalid' do
          let(:order) { Faker::Lorem.word }

          it 'responds with Unprocessable Entity status' do
            expect(response).to have_http_status(:unprocessable_entity)
          end

          it 'responds with a correct error message' do
            expect(response.body).to include(I18n.t('controllers.errors.api.v1.notes_controller.invalid_order_param'))
          end
        end
      end

      context 'when page is missing' do
        let(:page_size) { 10 }

        before { get :index, params: { page_size: page_size } }

        it 'responds with Unprocessable Entity status' do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'responds with an error message for invalid page' do
          expect(response.body).to include(I18n.t('controllers.errors.api.v1.notes_controller.invalid_page_param'))
        end
      end

      context 'when page_size is missing' do
        let(:page) { 1 }

        before { get :index, params: { page: page } }

        it 'responds with Unprocessable Entity status' do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'responds with an error message for invalid page_size' do
          expect(response.body).to include(I18n.t('controllers.errors.api.v1.notes_controller.invalid_page_param'))
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


        it 'responds with expected notes' do
          expect(response_body.to_json).to eq(expected)
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

  describe 'POST #create' do
    context 'when there is a user logged in' do
      include_context 'with authenticated user'

      context 'when title, type and content are present' do
        before { post :create, params: attributes }

        context 'when a note is created with valid params' do
          let(:attributes) { { note: { title: Faker::Lorem.sentence(word_count: 3), type: 'review', content: Faker::Lorem.sentence(word_count: 10) } } }

          it 'add a raw in the Note table' do
            expect(Note.count).to eq(1)
          end

          it 'responds with 200 status' do
            expect(response).to have_http_status(:created)
          end

          it 'respond with a success message' do
            expect(response.body).to include(I18n.t('controllers.errors.api.v1.notes_controller.success_note_create'))
          end
        end

        context 'when note type is not valid' do
          let(:attributes) { { note: { title: Faker::Lorem.sentence(word_count: 3), type: 'sinapsis', content: Faker::Lorem.sentence(word_count: 10) } } }

          it 'responds with Unprocessable Entity status' do
            expect(response).to have_http_status(:unprocessable_entity)
          end

          it 'responds with an error message for an invalid note type' do
            expect(response.body).to include(I18n.t('controllers.errors.api.v1.notes_controller.invalid_note_type'))
          end
        end

        context 'when content length is not valid' do
          let(:attributes) { { note: { title: Faker::Lorem.sentence(word_count: 3), type: 'review', content: 'word ' * 61 } } }

          it 'responds with Unprocessable Entity status' do
            expect(response).to have_http_status(:unprocessable_entity)
          end

          it 'responds with an error message for an invalid content length' do
            expect(response.body).to include(I18n.t('controllers.errors.api.v1.notes_controller.review_word_count',
                                                    max_word_limit: user.utility.max_word_valid_review))
          end
        end
      end

      context 'when required params are missing' do
        before { post :create, params: { note: { title: Faker::Lorem.sentence(word_count: 3), type: 'review' } } }

        it 'responds with Bad Request status' do
          expect(response).to have_http_status(:bad_request)
        end

        it 'responds with an error message for params missing' do
          expect(response.body).to include(I18n.t('controllers.errors.api.v1.notes_controller.params_missing'))
        end
      end
    end

    context 'when there is not a user logged in' do
      before { post :create, params: { note: { title: Faker::Lorem.sentence(word_count: 3), type: 'review', content: Faker::Lorem.sentence(word_count: 10) } } }

      it_behaves_like 'unauthorized'
    end
  end  

  describe 'GET #index_async' do
    context 'when the user is authenticated' do
      include_context 'with authenticated user'

      let(:author) { Faker::Book.author }
      let(:params) { { author: author } }
      let(:worker_name) { 'RetrieveNotesWorker' }
      let(:parameters) { [user.id, params.transform_keys(&:to_s)] }

      before { get :index_async, params: params }

      it 'returns status code accepted' do
        expect(response).to have_http_status(:accepted)
      end

      it 'returns the response id and url to retrive the data later' do
        expect(response_body.keys).to contain_exactly('response', 'job_id', 'url')
      end

      it 'enqueues a job' do
        expect(AsyncRequest::JobProcessor.jobs.size).to eq(1)
      end

      it 'creates the right job' do
        expect(AsyncRequest::Job.last.worker).to eq(worker_name)
      end

      it 'creates a job with given parameters' do
        expect(AsyncRequest::Job.last.params).to eq(parameters)
      end
    end

    context 'when the user is not authenticated' do
      before { get :index_async }

      it 'returns status code unauthorized' do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
