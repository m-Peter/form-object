Rails.application.routes.draw do
  
  resources :conferences
  resources :surveys
  resources :songs
  resources :projects
  resources :users
  resources :products

end
