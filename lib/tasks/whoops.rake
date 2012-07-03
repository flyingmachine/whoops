namespace :whoops do
  desc "Data migration to set the event count, as of 0.2.4"
  task :set_event_count => :environment do
    Whoops::EventGroup.all.each do |e|
      e.event_count = e.events.count
      e.save
    end
  end
end
