Rails.application.routes.draw do
  devise_for :users,
             path: '',
             path_names: { sign_in: 'login', sign_out: 'logout' },
             controllers: { sessions: 'users/sessions' }

  # مسار لاستعلام فيلم بواسطة UUID
  get '/movies/uuid/:uuid', to: 'movies#show_by_uuid'

  resources :movies, except: [:show]
  resources :film_ratings, only: [:create, :update, :destroy]
  resources :film_notes, only: [:create, :update, :destroy, :index]

  # مسار مخصص لاستعلام ملاحظات الفيلم باستخدام UUID الخاص بالفيلم
  get '/film_notes/movie_uuid/:uuid', to: 'film_notes#index_by_movie_uuid'

  resources :actors
  resources :movie_actors, only: [:create, :destroy]
  resources :genres
  resources :movie_genres, only: [:create, :destroy]

  devise_scope :user do
    post '/login/refresh', to: 'users/sessions#refresh'
  end
  get '/movies/uuid/:uuid', to: 'movies#show_by_uuid'

  resources :movies, param: :uuid, only: [:index, :show, :create] do
    member do
      post 'update', to: 'movies#update'
      post 'delete', to: 'movies#destroy'
    end
  end

  get 'image/:uuid', to: 'images#show'
  resources :film_notes, only: [:create, :update, :destroy, :index]
  get '/film_notes/movie/:movie_uuid', to: 'film_notes#index'
  post '/film_notes/:movie_uuid/update', to: 'film_notes#update'
  post '/film_notes/:movie_uuid/delete', to: 'film_notes#destroy'  

  get '/movie_details/:uuid', to: 'movie_details#show'

  post '/film_notes/:movie_uuid', to: 'film_notes#add_by_post'
  # إضافة تقييم جديد لفيلم باستخدام movie_uuid
  post '/film_ratings/:movie_uuid', to: 'film_ratings#add_by_post'
  # تحديث تقييم باستخدام movie_uuid
  post '/film_ratings/:movie_uuid/update', to: 'film_ratings#update_by_post'



  get "up" => "rails/health#show", as: :rails_health_check
end
