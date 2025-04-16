RSpec.shared_examples 'good responses' do
  it 'responds with expected notes' do
    expect(response_body.to_json).to eq(expected)
  end

  it 'responds with 200 status' do
    expect(response).to have_http_status(:ok)
  end
end
