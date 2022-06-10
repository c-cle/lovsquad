Rails.application.routes.draw do
  devise_for :users
  root to: 'pages#home'
  get '/success', to: 'authorizations#success'
  get '/code', to: 'authorizations#code'

  post '/channels/:id/join', to: 'channels#join', as: 'channel_join'

  resources :channels do
    resources :messages, only: [:index, :create, :destroy]
  end

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
