Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      # Auth routes
      post "auth/signup", to: "auth#signup"
      post "auth/login", to: "auth#login"
      post "auth/refresh", to: "auth#refresh"
      delete "auth/logout", to: "auth#logout"
      delete "auth/logout_all", to: "auth#logout_all"
      get "auth/me", to: "auth#me"
      get "auth/sessions", to: "auth#sessions"
      post "auth/password_reset/request", to: "auth#password_reset_request"
      patch "auth/password_reset", to: "auth#password_reset"
      # Add your other API routes here
      # resources :posts
      # resources :comments
    end
  end
  get "test/hello", to: "test#hello"

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end
