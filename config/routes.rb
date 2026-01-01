Rails.application.routes.draw do
  # rootの変更
  authenticated :user do
    root "home#index", as: :authenticated_root
  end

  unauthenticated do
    root "static_pages#top", as: :unauthenticated_root
  end

  # Deviseによるユーザー認証ルートの設定
  devise_for :users, controllers: {
    registrations: "users/registrations",
    sessions: "users/sessions",
    omniauth_callbacks: "users/omniauth_callbacks"
  }

  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  root "static_pages#top"

  get "/top", to: "static_pages#top"

  get "/terms", to: "static_pages#terms"

  get "home", to: "home#index"

  resources :mood_logs, only: [ :new, :create, :show, :edit, :update, :destroy ]

  # habitsリソースのルーティング設定
  resources :habits do
    member do
      patch :archive
      patch :restore
      delete :purge
    end
  end

  resources :habit_logs, only: [ :new, :create, :show, :edit, :update, :destroy ]

  resources :reactions, only: [ :show ], param: :date do
    member do
      get :share
    end
  end

  resources :calendars, only: [ :index, :show ], param: :date

  # reaction_today_pathで今日の振り返りに遷移
  get "reaction", to: redirect { |_, _|
    date = Date.current.to_s
    "/reactions/#{date}"
  }, as: :reaction_today
end
