Rails.application.routes.draw do
  resources :widgets

  resources :customers, except: [:show]
  get 'customers/widget_counts'

  devise_for :users

  resources :user_links, only: [:create, :destroy]

  root "customers#index"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
