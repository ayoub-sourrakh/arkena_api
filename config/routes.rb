Rails.application.routes.draw do
  devise_for :users,
    path: "auth",
    defaults: { format: :json },
    controllers: {
      registrations: "users/registrations"
    }
  get "/me", to: "profiles#show"
  get "/health", to: "health#show"
end
