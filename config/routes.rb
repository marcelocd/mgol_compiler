Rails.application.routes.draw do
  get '/home', to: 'compiler#home'

  resource :lexical_analyzer, only: :index
end
