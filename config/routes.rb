Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  post '/listener/:entity_id', to: 'listener#on_event'
end
