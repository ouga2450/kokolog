Rails.application.routes.draw do
  # Deviseによるユーザー認証ルートの設定
  devise_for :users, controllers: {
    registrations: "users/registrations",
    sessions: "users/sessions"
  }

  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  root "static_pages#top"

  # ログイン後のホーム画面
  get "home", to: "home#index"

  # mood_logsリソースのルーティング設定
  # indexは別途logsコントローラーで定義予定
  resources :mood_logs, only: [ :create, :show, :edit, :update, :destroy ]
end
