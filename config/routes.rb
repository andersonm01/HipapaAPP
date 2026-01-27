Rails.application.routes.draw do
  root 'home#index'
  get 'home/index'
  
  resources :orders, only: [:create] do
    member do
      post :confirm_items
      post :close_order
    end
  end
  resources :products
  
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
