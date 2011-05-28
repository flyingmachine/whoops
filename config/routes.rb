Rails.application.routes.draw do
  resources :event_groups, :as => "whoops_event_groups" do 
    resources :events
  end
  
  resources :events, :as => "whoops_events"
  
  root :to => "event_groups#index"
end