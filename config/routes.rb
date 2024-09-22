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
    ## /v1/items
    resources :items, controller: 'items' do
      collection do
        get :search
      end
      member do
        get :audit_log
      end
    end    
  end
end