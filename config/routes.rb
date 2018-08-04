Rails.application.routes.draw do
  get 'notice/index'
  get 'notice/show/:id' => 'notice#show'
  get 'notice/images'
  get 'notice/attacheds'
  root 'notice#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
