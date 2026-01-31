Rails.application.routes.draw do
  root 'home#index'
  get 'home/index'
  get 'pedido/:id', to: 'home#index', as: :pedido, constraints: { id: /\d+/ }

  # ActionCable mount
  mount ActionCable.server => '/cable'

  resources :orders, only: [:create] do
    member do
      post :confirm_items
      post :close_order
      patch :update_servicio
    end
  end
  resources :products
  
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
