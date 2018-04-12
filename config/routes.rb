Rails.application.routes.draw do
  mount ForestLiana::Engine => '/forest'
  devise_for :users

  namespace :api do
    namespace :v1 do
      get "properties/download_to_csv", to: "properties#download_to_csv"
    end
  end
end
