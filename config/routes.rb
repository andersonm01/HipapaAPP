Rails.application.routes.draw do
  # Auth
  get  '/login',  to: 'sessions#new',     as: :login
  post '/login',  to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy', as: :logout
  get  '/auth/:provider/callback', to: 'sessions#omniauth'
  get  '/auth/failure',            to: 'sessions#omniauth_failure'

  # Admin
  namespace :admin do
    resources :users do
      member { patch :toggle_active }
    end
  end

  root 'home#index'
  get 'home/index'
  get 'pedido/:id', to: 'home#index', as: :pedido, constraints: { id: /\d+/ }

  # ActionCable mount
  mount ActionCable.server => '/cable'

  resources :orders, only: [:create, :destroy] do
    member do
      post :confirm_items
      post :close_order
      patch :update_servicio
      patch :update_kitchen_status
    end
  end
  resources :products

  get "reportes", to: "reports#index", as: :reportes
  get "cocina",   to: "cocina#index",  as: :cocina

  # Configuración y proxy de impresora térmica (en HomeController para evitar errores de forgery)
  get "print/config", to: redirect("/printer/config")
  get "printer/config", to: "home#printer_config", as: :printer_config
  get "printer/ping", to: "home#printer_ping"
  get "printer/impresoras", to: "home#printer_impresoras"
  post "printer/imprimir", to: "home#printer_imprimir"
  post "printer/imprimir_raw", to: "home#printer_imprimir_raw"
  get "printer/qz_cert", to: "home#printer_qz_cert"
  get "printer/qz_sign", to: "home#printer_qz_sign"

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  post '/qz/sign', to: 'qz#sign'
end
