require 'rails_helper'

RSpec.describe Github::Repositories do
  let(:body_with_items) do
    { 'total_count' => 1,
      'items' => [{ 'full_name' => 'test repo',
                    'html_url' => 'https://www.example.com' }] }.to_json
  end
  let(:body_with_error) do
    { 'message' => 'error message' }.to_json
  end
  let(:github_full_url) do
    Rails.application.secrets.github[:base_url] +
      "#{Rails.application.secrets.github[:search_repositories_path]}?page=2&per_page=25&q=test"
  end

  describe 'initialize' do
    it 'assigns values to @search_term, @page, @per_page' do
      subject = Github::Repositories.new('test', 2, 25)

      expect(subject.instance_variable_get('@search_terms')).to eq('test')
      expect(subject.instance_variable_get('@page')).to eq(2)
      expect(subject.instance_variable_get('@per_page')).to eq(25)
    end

    it 'has a default values for page and per_page' do
      subject = Github::Repositories.new('test')

      expect(subject.instance_variable_get('@page')).to eq(1)
      expect(subject.instance_variable_get('@per_page')).to eq(10)
    end
  end

  describe 'search_public' do
    it 'returns list of items, total number of items' do
      stub_request(:get, github_full_url)
        .with(
          headers: {
            'Accept' => 'application/vnd.github.v3+json',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Authorization' => 'Basic Og==',
            'Host' => 'api.github.com',
            'User-Agent' => 'Ruby'
          }
        ).to_return(status: 200, body: body_with_items)
      subject = Github::Repositories.new('test', 2, 25).search

      expect(subject).to match_array([[{ 'repository_name' => 'test repo',
                                         'repository_url' => 'https://www.example.com' }], 1, nil])
    end

    context 'Errors' do
      before do
        stub_request(:get, github_full_url)
          .with(
            headers: {
              'Accept' => 'application/vnd.github.v3+json',
              'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'Authorization' => 'Basic Og==',
              'Host' => 'api.github.com',
              'User-Agent' => 'Ruby'
            }
          ).to_return(status: 401, body: body_with_error)
      end

      it 'returns empty array of items, 0 as count and an error' do
        subject = Github::Repositories.new('test', 2, 25).search
        expect(subject).to match_array([[], 0, 'internal error'])
      end

      it 'logs the error' do
        allow(Rails.logger).to receive(:error)
        expect(Rails.logger).to receive(:error).with("Error: 401 - #{JSON.parse(body_with_error)['message']}")

        Github::Repositories.new('test', 2, 25).search
      end
    end
  end
end
