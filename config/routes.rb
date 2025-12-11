Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions'
  }

  root to: 'home#index'
  resources :pets, only: [:index, :show] do
    resources :requests, only: [:create]
  end

  resources :requests, only: [:index]

  namespace :admin do
    root to: 'dashboard#index'
    get 'dashboard', to: 'dashboard#index'
    resources :pets do
      member do
        patch :mark_as_adopted
        patch :mark_as_available
      end
    end
    resources :requests do
      member do
        post :approve
        post :reject
      end
    end
    resources :users do
      member do
        patch :make_admin
        patch :remove_admin
      end
    end
  end
end
