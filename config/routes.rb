Rails.application.routes.draw do
  devise_for :users, path: '', path_names: {
    sign_in: 'sign_in',
    sign_out: 'sign_out',
    registration: 'sign_up'
  },
  controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }

  scope :v1 do
    ## /v1/items/search?query=...
    namespace :items do
      resources :search, only: [:index]
    end
    ## /v1/items
    resources :items, controller: 'items', only: [:index, :show]
  end
end