class Whoops::EventGroup
  # notifier responsible for creating identifier from notice details
  include Mongoid::Document
  include FieldNames
  
  [
    :service,
    :environment,
    :event_type,
    :message,
    :event_group_identifier,
    :logging_strategy_name
  ].each do |string_field|
    field string_field, :type => String
  end
  
  field :last_recorded_at, :type => DateTime
  field :archived, :type => Boolean, :default => false
  field :event_count, :type => Integer, :default => 0

  class << self
    def handle_new_event(params)
      identifying_params = params.slice(*Whoops::EventGroup.identifying_fields)
      event_group = Whoops::EventGroup.first(:conditions => identifying_params)
      
      if event_group
        event_group.attributes = params
      else
        event_group = Whoops::EventGroup.new(params)
      end
      
      if event_group.valid?
        event_group.send_notifications
        event_group.archived = false
        event_group.event_count += 1
        event_group.save
      end

      event_group
    end
  end
  
  has_many :events, :class_name => "Whoops::Event"
  
  validates_presence_of :event_group_identifier, :event_type, :service, :message
  
  def self.identifying_fields
    field_names - ["message", "last_recorded_at"]
  end
  
  # @return sorted set of all applicable namespaces
  def self.services
    all.distinct(:service).sort
  end

  def should_send_notifications?
    (archived || new_record) && Rails.application.config.whoops_sender
  end
  
  def send_notifications
    return unless should_send_notifications?
    matcher = Whoops::NotificationSubscription::Matcher.new(self)
    Whoops::NotificationMailer.event_notification(self, matcher.matching_emails).deliver unless matcher.matching_emails.empty?
  end
end
