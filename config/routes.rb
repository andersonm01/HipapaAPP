Rails.application.routes.draw do
  # Auth
  get    '/login',  to: 'sessions#new',     as: :login
  post   '/login',  to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy', as: :logout
  get    '/auth/:provider/callback', to: 'sessions#omniauth'
  get    '/auth/failure',            to: 'sessions#omniauth_failure'

  # Admin
  namespace :admin do
    resources :users do
      member { patch :toggle_active }
    end
  end

  # POS root
  root 'home#index'
  get  'home/index'
  get  'pedido/:id', to: 'home#index', as: :pedido, constraints: { id: /\d+/ }

  # ActionCable
  mount ActionCable.server => '/cable'

  # Orders (POS)
  resources :orders, only: [:create, :destroy] do
    member do
      post   :confirm_items
      post   :close_order
      post   :cancel_order
      patch  :update_servicio
      patch  :update_kitchen_status
      delete 'items/:item_id', to: 'orders#destroy_item', as: :destroy_item
    end
  end

  # Products con receta anidada
  resources :products do
    resource :recipe, only: [:show, :update], controller: 'recipes'
  end

  # Clientes
  resources :customers do
    member { get :orders_history }
  end

  # Salsas
  resources :sauces

  # Ingredientes
  resources :ingredients do
    member { post :adjust_stock }
  end

  # Caja
  resources :cash_registers, only: [:index, :show] do
    collection { post :open }
    member do
      post :close
      post :add_movement
    end
  end

  # Facturas
  resources :invoices, only: [:index, :show] do
    member do
      get  :print
      post :void
    end
  end

  # Configuración del negocio
  resource :business_settings, only: [:show, :update]

  # Módulos de reportes y cocina
  get "reportes", to: "reports#index", as: :reportes
  get "cocina",   to: "cocina#index",  as: :cocina

  # Página pública (pedidos online)
  namespace :public do
    get  '/',      to: 'menu#index',    as: :menu
    post '/pedido', to: 'orders#create', as: :order
    get  '/pedido/:id/estado', to: 'orders#status', as: :order_status
  end

  # Impresora
  get  "print/config",          to: redirect("/printer/config")
  get  "printer/config",        to: "home#printer_config",    as: :printer_config
  get  "printer/ping",          to: "home#printer_ping"
  get  "printer/impresoras",    to: "home#printer_impresoras"
  post "printer/imprimir",      to: "home#printer_imprimir"
  post "printer/imprimir_raw",  to: "home#printer_imprimir_raw"
  get  "printer/qz_cert",       to: "home#printer_qz_cert"
  get  "printer/qz_sign",       to: "home#printer_qz_sign"

  post '/qz/sign', to: 'qz#sign'
end
