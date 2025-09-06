Rails.application.routes.draw do
  mount ActionCable.server => "/cable"
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  # Only allow authenticated users to get access
  # to the Sidekiq web interface
  require 'sidekiq/web'
  authenticate :admin_user do
    mount Sidekiq::Web => '/sidekiq'
  end

  devise_for :users, controllers: {
      sessions: 'users/sessions',
      registrations: 'users/registrations',
      passwords: 'users/passwords',
      confirmations: 'users/confirmations',
      omniauth_callbacks: 'users/omniauth_callbacks'
  }

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root 'home#landing'
  get '/email_template', to: 'home#email_template', as: 'email_template'
  get '/about', to: 'home#about', as: 'about'
  get '/contact', to: 'home#contact', as: 'contact'
  get '/animation', to: 'home#animation'
  get '/use_reference', to: 'home#use_reference', as: 'reference'

  resources :messages do
    member do
      get :profile
    end
  end

  resources :users, shallow: true do
    collection do
      get :notifications
      post :mark_notification_read
      patch :update_referral_code
    end
    member do
      get :show_verify
      post :verify
      post :resend
      get :change_password
      patch :update_password
      patch :deactivate_account
      patch :activate_account
      patch :toggle_text_alert
      patch :toggle_advanced_search
    end
  end

  resources :orders, except: %i[edit update destroy] do
    member do
      post :success
      post :fail
      post :cancel
    end
  end

  resources :partner_preferences do
  end

  resources :marriage_profiles do
    collection do
      get :blocked_profiles
      get :pending_profiles
      get :requested_profiles
      get :refferel_code
    end
    member do
      get :profile_info
      get :dashboard
      get :switch
      get :edit_about
      patch :update_about
      post :send_request
      patch :accept_request
      patch :reject_request
      patch :cancel_request
      patch :remove_profile
      patch :block_profile
      patch :unblock_profile
      patch :change_profile
      patch :change_photo
      get :requested_profiles
      get :search_page
      get :search
      post :search
    end
  end

  resources :advertiser_profiles
  resources :occupations
  resources :appearances
  resources :family_members
  resources :marriage_informations
  resources :life_styles
  resources :hobbies_and_interests
  resources :cultural_values
  resources :academic_informations
  resources :favourites do
    collection do
      delete :remove
    end
  end

  resources :blogs
  resources :market_places
  resources :terms_of_uses
  resources :privacy_policies
  resources :faqs
  resources :assisted_services
  resources :precautionary_measures
  resources :process_flows, as: :how_it_works, path: :how_it_works
  resources :customer_supports
  resources :privacy_settings do
    member do
      put :toggle_update
    end
  end
  resources :chat_friendships do
    member do
      post :send_request
      patch :accept_request
      patch :reject_request
    end
  end
end
