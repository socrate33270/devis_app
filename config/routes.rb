Rails.application.routes.draw do
  devise_for :users
  # Routes pour les clients, avec la possibilité de créer des devis depuis un client
  resources :clients do
    resources :devis, only: [:new, :create]
  end
  # Routes pour les devis existants (accès direct)
  resources :devis, except: [:new, :create, :index] do
    member do
      get :generate_offer
      patch :update_offer
      get :show_original_offer
      post :set_territoire
      post :set_type_offre
      get :download_offer_pdf # Nouvelle route ajoutée ici
      # ... autres routes possibles ...
    end
  end
  
  resources :offer_templates
  
  # Routes avec possibilité de créer des emails
  resources :email_templates do
    member do
      get :preview
    end
  end
  
  # Rediriger les anciennes URL /devis vers la liste des clients
  get '/devis', to: redirect('/clients')
  get "up" => "rails/health#show", as: :rails_health_check
  # Changer la racine pour pointer vers la liste des clients au lieu des devis
  root "clients#index"
end