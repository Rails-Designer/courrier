# frozen_string_literal: true

Courrier::Engine.routes.draw do
  resources :previews, only: %w[show], constraints: {id: /.*\.html/}
  resource :cleanup, only: %w[create], module: "previews"

  root "previews#index"
end
