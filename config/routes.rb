Rails.application.routes.draw do
  # Letter Opener Web - Preview emails in development at /letter_opener
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions',
    passwords: 'users/passwords'
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

  resources :requests, only: [:index, :show]
  
  # User's saved pets (liked and wishlisted)
  get 'my_pets', to: 'interactions#index', as: :my_pets
  get 'my_likes', to: 'interactions#likes', as: :my_likes
  get 'my_wishlist', to: 'interactions#wishlist_list', as: :my_wishlist
  
  # User preferences
  resource :user_preferences, only: [:edit, :create, :update]

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
        post :mark_as_completed
        post :mark_as_no_show
        post :reschedule
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
