Rails.application.routes.draw do
  mount ActionCable.server => '/cable'

  devise_for :auths, controllers: { confirmations: 'users/confirmations', sessions: 'sessions' }

  root 'master_admins/dashboard#index', as: :authenticated_root

  namespace :master_admins, path: 'admin', as: :admin do
    resources :companies do
      member do
        get :logisticians
      end
    end
    resources :trailers do
      resources :access_permissions, shallow: true
      resources :cameras, shallow: true, controller: 'trailer_cameras', only: %i[index] do
        patch :enable
        patch :disable
      end
    end
    resources :logisticians do
      member do
        patch :assign_trailer
        patch :unassign_trailer
      end
    end
    resources :custom_routes
    resources :drivers
  end

  namespace :api, format: :json do
    namespace :v1 do
      scope module: :trailers do
        resources :sensors do
          scope module: :sensors do
            resources :events, only: :index
          end
        end
      end

      resource :logistician, controller: :logistician, only: %i[update show] do
        collection do
          patch :update_password
        end
      end

      resources :trailers, only: %i[show index] do
        member do
          patch :update_status
          patch :read_status
        end

        scope module: :trailers do
          resources :route_logs, only: :index, path: :route_log
          resources :events, only: %[index], shallow: true do
            member { patch :resolve_alarm }
          end
          resources :media, only: :index do
            collection do
              post :request_media
            end
          end
          resources :sensors, only: :index
        end
      end

      resources :sensor_settings, only: :update
      resources :people, only: :index

      mount_devise_token_auth_for 'Auth', at: 'auth', skip: %i[omniauth_callbacks], controllers: {
        sessions:  'overrides/sessions',
        token_validations: 'overrides/token_validations'
      }
    end

    namespace :safeway do
      resources :media, param: :uuid, only: [] do
        member do
          post :upload
          post :failure
        end
      end
    end
  end

  require 'sidekiq/web'
  authenticate :auth, lambda { |auth| auth.master_admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end
end
