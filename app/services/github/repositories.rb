module Github
  class Repositories
    def initialize(search_terms, page = 1, per_page = 10)
      @search_terms = search_terms
      @page = page
      @per_page = per_page
    end

    def search
      result = HttpRequests.new(search_url, fetch_params, fetch_headers, fetch_auth, true).send_get_request
      body = JSON.parse(result.body)
      if result.code.to_i >= 400
        Rails.logger.error "Error: #{result.code} - #{body['message']}"
        [[], 0, 'internal error']
      else
        [build_response(body), body['total_count'], nil]
      end
    end

    private

    def search_url
      Rails.application.secrets.github[:base_url] + Rails.application.secrets.github[:search_repositories_path]
    end

    def fetch_params
      { q: @search_terms, page: @page, per_page: @per_page }
    end

    def fetch_headers
      { Accept: 'application/vnd.github.v3+json' }
    end

    def fetch_auth
      { username: Rails.application.secrets.github['username'],
        token: Rails.application.secrets.github['authorization_token'] }
    end

    def build_response(body)
      body['items'].map { |item| { 'repository_name' => item['full_name'], 'repository_url' => item['html_url'] } }
    end
  end
end
