Rails.application.routes.draw do
  get '/', to: 'syntatic_analyzer#index'

  resources :lexical_analyzer, only: :index
  resources :syntatic_analyzer, only: :index
end
