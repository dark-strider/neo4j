Graph::Application.routes.draw do
  root to: 'companies#index'
  resources :countries, except: :show

  resources :companies, except: :show do
    resources :incompanies, except: [:index, :show], path: 'workers'
    member do
      get :workers
      get :set
     post :setup
    end
  end

  resources :faces do
    member do
      get :set
     post :setup
    end
  end
end