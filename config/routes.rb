Rails.application.routes.draw do
  mount ForestLiana::Engine => '/forest'
  devise_for :users

  # Routes for API actions
  namespace :api do
    namespace :v1 do
      get "properties/download_to_csv", to: "properties#download_to_csv"
    end
  end

  # Routes for tracking clicks on properties
  get "tracking/:alert_id/:property_id", to: "tracking#redirect_to_listing"


  # Sidekiq Web UI, only for admins.
  require "sidekiq/web"
  authenticate :user, lambda { |u| u.admin } do
    mount Sidekiq::Web => '/sidekiq'
  end
end
