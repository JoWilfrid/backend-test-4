# frozen_string_literal: true

Rails.application.routes.draw do
  resources :calls do
    collection do
      post :failure
      post :update_status
      post :register_message
    end
  end

  root to: 'calls#index'
end
