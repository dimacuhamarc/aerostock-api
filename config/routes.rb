Rails.application.routes.draw do
  get 'item_search/index'
  get 'item_search/search'
  get 'items/index'
  get 'items/show'
  devise_for :users, path: '', path_names: {
    sign_in: 'sign_in',
    sign_out: 'sign_out',
    registration: 'sign_up'
  },
  controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }
end