Rails.application.routes.draw do

  get 'attachment/:id/:filename.:extension' => 'attachments#show'
  resources :product_categories
  resources :products do
    resources :variants
  end
  resources :orders do
    post :search, :on => :collection
    post :accept, :on => :member
    post :reject, :on => :member
    post :ship, :on => :member
    get :despatch_note, :on => :member
    resources :payments, :only => [:create, :destroy] do
      match :refund, :on => :member, :via => [:get, :post]
    end
  end
  resources :stock_level_adjustments, :only => [:index, :create]
  resources :delivery_services do
    resources :delivery_service_prices
  end
  resources :tax_rates
  resources :users
  resources :countries
  resources :attachments, :only => :destroy

  get 'settings'=> 'settings#edit'
  post 'settings' => 'settings#update'
  
  get 'login' => 'sessions#new'
  post 'login' => 'sessions#create'
  match 'login/reset' => 'sessions#reset', :via => [:get, :post]
  
  delete 'logout' => 'sessions#destroy'
  root :to => 'dashboard#home'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
