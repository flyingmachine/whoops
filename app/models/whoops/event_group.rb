class Whoops::EventGroup
  # notifier responsible for creating identifier from notice details
  include Mongoid::Document
  include FieldNames
  
  [
    :service,
    :environment,
    :event_type,
    :message,
    :identifier,
    :logging_strategy_name
  ].each do |string_field|
    field string_field, :type => String
  end
  
  field :last_recorded_at, :type => DateTime
  field :ignore_until_next_occurrence, :type => Boolean, :default => false
  field :notify_on_next_occurrence, :type => Boolean, :default => true

  class << self
    def handle_new_event(params)
      event_group_params = clean_params(params)      
      event_group = Whoops::EventGroup.first(:conditions => event_group_params.slice(*Whoops::EventGroup.identifying_fields))
      
      if event_group
        event_group.attributes = event_group_params
      else
        event_group = Whoops::EventGroup.new(event_group_params)
      end
      
      event_group.stop_ignoring
      event_group.send_notifications
      
      event_group.save
      event_group
    end
    
    def clean_params(params)
      event_group_params = params.slice(*Whoops::EventGroup.field_names)
      event_group_params[:identifier] = params[:event_group_identifier]
      event_group_params[:last_recorded_at] = params[:event_time]
      event_group_params
    end
  end
  
  has_many :events, :class_name => "Whoops::Event"
  
  validates_presence_of :identifier, :event_type, :service, :message
  
  after_validation :send_notifications
  
  def self.identifying_fields
    field_names - ["message", "last_recorded_at"]
  end
  
  # @return sorted set of all applicable namespaces
  def self.services
    services = SortedSet.new
    previous_service = []
    all(:sort => [[:service, :asc]]).each do |group|
      services << group.service
      split = group.service.split(".")
      common = (previous_service & split)
      services << common.join(".") unless common.blank?
      previous_service = split
    end
    services
  end
  
  def stop_ignoring
    self.ignore_until_next_occurrence = false;
    self.notify_on_next_occurrence = true;
  end
  
  def send_notifications
    return unless self.notify_on_next_occurrence
    matcher = Whoops::NotificationRule::Matcher.new(self)
    Whoops::NotificationMailer.event_notification(self, matcher.matches).deliver unless matcher.matches.empty?
    self.notify_on_next_occurrence = false
  end
  
end