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
  field :notify_on_next_occurrence, :type => Boolean, :default => true
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
        event_group.archived = false
        event_group.handle_archival
        event_group.event_count += 1
        event_group.send_notifications
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

  def handle_archival
    if self.archived_change && !self.new_record?
      if self.archived
        self.notify_on_next_occurrence = true
      else
        self.notify_on_next_occurrence = false
      end
    end
    true
  end
  
  def send_notifications
    return if !self.notify_on_next_occurrence || !Rails.application.config.whoops_sender
    matcher = Whoops::NotificationRule::Matcher.new(self)
    Whoops::NotificationMailer.event_notification(self, matcher.matches.collect(&:email)).deliver unless matcher.matches.empty?
    self.notify_on_next_occurrence = false
  end
end
