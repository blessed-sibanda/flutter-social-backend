Rails.application.routes.draw do
  resources :posts, except: %i[update] do
    member do
      put :like
      put :unlike
    end
    resources :comments, only: [:create, :destroy, :index]
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :users, only: %i[index show] do
    collection do
      get :people
      get :me
    end

    member do
      get :posts
      scope controller: :relationships do
        put :follow
        put :unfollow
        get :followers
        get :following
      end
    end
  end
  devise_for :users, 
            path: "",
            path_names: {
              sign_in: "api/login",
              sign_out: "api/logout",
              registration: "api/signup",
            },
            controllers: {
              sessions: "auth/sessions",
              registrations: "auth/registrations",
              passwords: 'auth/passwords',
            }
end
