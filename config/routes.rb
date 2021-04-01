Rails.application.routes.draw do
  get '/home', to: 'compiler#home'

  resources :lexical_analyzer, only: :index
end
