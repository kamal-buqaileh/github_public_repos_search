require 'rails_helper'

RSpec.describe GithubRepositoriesController do
  describe 'Get index' do
    it 'response with 200 http status' do
      get :index

      expect(response).to have_http_status(:ok)
    end
  end

  describe 'Get search' do
    before do
      allow_any_instance_of(Github::Repositories).to receive(:search).and_return(true)
    end

    it 'calls Github::Repositories service' do
      expect_any_instance_of(Github::Repositories).to receive(:search)

      get :search,
          params: { github_search: { search_terms: 'test' } },
          xhr: true
    end

    it 'raise error if params does not have github_search key' do
      expect { get :search, xhr: true }.to raise_error(ActionController::ParameterMissing)
    end
  end
end
