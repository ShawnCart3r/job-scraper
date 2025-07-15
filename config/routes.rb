Rails.application.routes.draw do
  root "jobs#index"

  resources :jobs, only: [:index] do
    collection do
      post :refresh
      get :search
    end
  end
end