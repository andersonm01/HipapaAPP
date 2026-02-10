Rails.application.routes.draw do
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
    end
  end
  resources :products

  get "reportes", to: "reports#index", as: :reportes

  # Configuración y proxy de impresora térmica (en HomeController para evitar errores de forgery)
  get "print/config", to: redirect("/printer/config")
  get "printer/config", to: "home#printer_config", as: :printer_config
  get "printer/ping", to: "home#printer_ping"
  get "printer/impresoras", to: "home#printer_impresoras"
  post "printer/imprimir", to: "home#printer_imprimir"
  post "printer/imprimir_raw", to: "home#printer_imprimir_raw"

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
