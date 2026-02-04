Rails.application.routes.draw do
  # Authentication routes
  get "/login", to: "sessions#new"
  post "/login", to: "sessions#create"
  delete "/logout", to: "sessions#destroy"

  # Resource routes
  resources :users
  resources :students

  # Feature namespaces
  namespace :my_courses do
    get "selected_courses", to: "selected_courses#index"
    resources :select_courses, only: [:index, :create]
  end

  # Static pages
  get "welcome/index"
  root "welcome#index"

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
