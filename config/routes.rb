Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root "application#index"  
  get "/public-key", to: "application#stripe_public_key"
  post "/create-setup-intent", to: "application#create_setup_intent"
  post "/webhook", to: "application#webhook"
end
