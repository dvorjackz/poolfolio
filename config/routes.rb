Rails.application.routes.draw do
  resources :teams
  devise_for :users
  root 'static_pages#home'

  get '/help', to: 'static_pages#help'
  get '/about', to: 'static_pages#about'
  get '/contact', to: 'static_pages#contact'
  get '/signup', to: 'static_pages#signup'
  get '/login', to: 'static_pages#login'

  resources :users

  get "*path", to: redirect('/')
end
