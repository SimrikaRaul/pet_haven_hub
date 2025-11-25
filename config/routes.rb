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
    resources :pets
    resources :requests do
      member do
        post :approve
        post :reject
      end
    end
  end
end
