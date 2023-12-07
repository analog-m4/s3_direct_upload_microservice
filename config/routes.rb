Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  post 'create_presigned_url', to: 'uploaded_files#create_presigned_url'
  post 'upload_complete', to: 'uploaded_files#upload_complete'
  post 'api/v1/create', to: 'api/v1/analogs#create'
end

