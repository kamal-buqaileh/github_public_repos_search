Rails.application.routes.draw do
  resources :github_repositories, only: :index do
    collection do
      get :search
    end
  end

  root to: 'github_repositories#index'
end
