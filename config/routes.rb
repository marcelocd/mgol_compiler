Rails.application.routes.draw do
  get '/', to: 'lexical_analyzer#index'

  resources :lexical_analyzer, only: :index
end
