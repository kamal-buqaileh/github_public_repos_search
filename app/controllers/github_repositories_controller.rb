class GithubRepositoriesController < ApplicationController
  def search
    @repositories_hash,
      @total_number_of_repositories,
      @error = Github::Repositories.new(search_params['search_terms'],
                                        search_params['page'],
                                        search_params['per_page']).search
  end

  private

  def search_params
    params.require(:github_search).permit(:search_terms, :page, :per_page)
  end
end
