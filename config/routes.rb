Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/this_is_admin_page', as: 'rails_admin'
  resources :webhook, :only => [:create]
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
