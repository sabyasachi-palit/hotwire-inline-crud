Rails.application.routes.draw do
  root to: redirect("/products")
  resources :products do
    collection do
      get :product_list
    end
  end
end
