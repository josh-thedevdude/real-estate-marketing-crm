Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Custom health check endpoint
  get "health", to: "health#index"

  # API routes
  namespace :api do
    namespace :v1 do
      # Authentication routes
      post 'auth/login', to: 'authentication#login'
      post 'auth/logout', to: 'authentication#logout'
      get 'auth/me', to: 'authentication#me'
      
      # Resources
      resources :organizations
      
      resources :users do
        collection do
          post :accept_invitation
        end
      end
    end
  end

  # Defines the root path route ("/")
  # root "posts#index"
end
