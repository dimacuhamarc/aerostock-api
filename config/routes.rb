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
    resources :items, controller: 'items'
    resources :item_search, controller: 'item_search', only: [:index]
  end

end