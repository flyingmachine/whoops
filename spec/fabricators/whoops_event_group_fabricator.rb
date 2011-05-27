Fabricator("Whoops::EventGroup") do
  service "app"
  environment "production"
  event_type "error"  
  message "ArgumentError"
  identifier "3r42"
  last_recorded_at { rand(300).seconds.ago }
end
