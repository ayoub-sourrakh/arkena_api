Rails.application.routes.draw do
  devise_for :users
  get "/health", to: "health#show"
end
