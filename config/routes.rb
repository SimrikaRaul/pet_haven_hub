Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions'
  }

  root to: 'home#index'
  get 'about', to: 'home#about'
  
  resources :pets, only: [:index, :show] do
    resources :requests, only: [:new, :create]
    
    # Interaction routes for likes and wishlists
    member do
      post :like, to: 'interactions#like'
      delete :like, to: 'interactions#unlike'
      post :wishlist, to: 'interactions#wishlist'
      delete :wishlist, to: 'interactions#remove_from_wishlist'
    end
  end

  resources :requests, only: [:index]
  
  # User's saved pets (liked and wishlisted)
  get 'my_pets', to: 'interactions#index', as: :my_pets
  
  # User preferences and recommendations
  resource :user_preferences, only: [:edit, :create, :update]
  resources :recommendations, only: [:index]

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
