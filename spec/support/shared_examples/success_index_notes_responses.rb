RSpec.shared_examples 'success index notes responses' do
  let(:expected_note_keys) { %w[id title type content_length] }
   
  it 'responds with the expected note keys' do
    expect(response_body.first.keys).to match_array(expected_note_keys)
  end

  it 'responds with 200 status' do
    expect(response).to have_http_status(:ok)
  end
end
