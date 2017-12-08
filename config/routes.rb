Osem::Application.routes.draw do

  if ENV['OSEM_ICHAIN_ENABLED'] == 'true'
    devise_for :users, controllers: { registrations: :registrations }
  else
    devise_for :users,
               controllers: {
                   registrations: :registrations, confirmations: :confirmations,
                   omniauth_callbacks: 'users/omniauth_callbacks' },
               path: 'accounts'
  end

  # Use letter_opener_web to open mails in browser (e.g. necessary for Vagrant)
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  # custom error pages
  match "/404", :to => "errors#not_found", :via => :all
  match "/500", :to => "errors#internal_server_error", :via => :all

  resources :users, except: [:new, :index, :create, :destroy]

  namespace :portal do
    resources :sponsors, except: [:new, :create, :destroy] do
      resources :conferences, except: [:new, :create, :destroy] do
        resources :codes, only: [:show]
        resources :benefit_responses
      end
    end
  end

  namespace :admin do
    resources :users
    resources :users do
      member do
        patch :toggle_confirmation
      end
    end
    resources :sponsors
    resources :comments, only: [:index]
    resources :conferences do
      resource :contact, except: [:index, :new, :create, :show, :destroy]
      resources :schedules, only: [:index, :create, :show, :update, :destroy]
      resources :event_schedules, only: [:create, :update, :destroy]
      get 'commercials/render_commercial' => 'commercials#render_commercial'
      resources :commercials, only: [:index, :create, :update, :destroy]
      get '/volunteers_list' => 'volunteers#show'
      get '/volunteers' => 'volunteers#index', as: 'volunteers_info'
      patch '/volunteers' => 'volunteers#update', as: 'volunteers_update'

      resources :registrations, except: [:create, :new] do
        member do
          patch :toggle_attendance

        end
      end

      # Singletons
      resource :splashpage
      resource :venue do
        get 'venue_commercial/render_commercial' => 'venue_commercials#render_commercial'
        resource :venue_commercial, only: [:create, :update, :destroy]
        resources :rooms, except: [:show]
      end
      resource :registration_period
      resource :sponsorship_info
      resource :program do
        resource :cfp
        resources :tracks
        resources :event_types
        resources :difficulty_levels
        resources :events do
          member do
            patch :toggle_attendance
            get :registrations
            get :attendees
            post :comment
            patch :accept
            patch :confirm
            patch :cancel
            patch :reject
            patch :unconfirm
            patch :restart
            get :vote
          end
        end
      end

      resources :tickets do
        member do
          patch :up
          patch :down
        end
      end
      resources :sponsorships, except: [:show]
      resources :lodgings, except: [:show]
      resources :activities, except: [:show]
      resources :benefits, except: [:show]
      resources :sponsorship_levels_benefits, except: [:show]
      resources :targets, except: [:show]
      resources :campaigns, except: [:show]
      resources :emails, only: [:show, :update, :index]
      resources :roles, except: [ :new, :create ] do
        member do
          post :toggle_user
        end
      end

      resources :sponsorship_levels, except: [:show] do
        member do
          patch :up
          patch :down
        end
      end

      resources :questions do
        collection do
          patch :update_conference
        end
      end

      resources :policies do
        collection do
          patch :update_conference
        end
      end

      resources :codes do
        collection do
          patch :update_conference
        end
      end
    end

    get '/revision_history' => 'versions#index'
    get '/revision_history/:id/revert_object' => 'versions#revert_object', as: 'revision_history_revert_object'
    get '/revision_history/:id/revert_attribute' => 'versions#revert_attribute', as: 'revision_history_revert_attribute'
  end

  resources :conferences, only: [:index, :show] do
    resource :program, only: [] do
      resources :proposals, except: :destroy do
        get 'commercials/render_commercial' => 'commercials#render_commercial'
        resources :commercials, only: [:create, :update, :destroy]
        member do
          get :registrations
          patch '/withdraw' => 'proposals#withdraw'
          get :registrations
          patch '/confirm' => 'proposals#confirm'
          patch '/restart' => 'proposals#restart'
          post :comment
          get :vote
        end
      end
    end

    # TODO: change conference_registrations to singular resource
    resource :conference_registration, path: 'register'
    resources :tickets, only: [:index]
    resources :ticket_purchases, only: [:create, :destroy]
    resources :payments, only: [:index, :new, :create]
    resources :physical_ticket, only: [:index, :show, :update] do
      member do
        get :claim
        patch :assign
      end
    end

    resource :subscriptions, only: [:create, :destroy]
    resource :sponsorships, only: [:show]

    resource :schedule, only: [:show] do
      member do
        get :events
        get :today_events
      end
    end
  end

  namespace :api, defaults: {format: 'json'} do
    namespace :v1 do
      resources :conferences, only: [ :index, :show ] do
        resources :rooms, only: :index
        resources :tracks, only: :index
        resources :speakers, only: :index
        resources :events, only: :index
      end
      resources :rooms, only: :index
      resources :tracks, only: :index
      resources :speakers, only: :index
      resources :events, only: :index
    end
  end

  get '/admin' => redirect('/admin/conferences')
  get '/portal' => redirect('/portal/sponsors')

  get '/conferences' => 'conferences#index'
  get '/2017' => 'conferences#show'
  root to: 'conferences#index', via: [:get, :options]
  #root to: 'conferences#redirect_to_current'
end
