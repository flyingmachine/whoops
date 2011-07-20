class Whoops::EventGroup
  # notifier responsible for creating identifier from notice details
  include Mongoid::Document
  include FieldNames
  
  [:service, :environment, :event_type, :message, :identifier, :logging_strategy_name].each do |string_field|
    field string_field, :type => String
  end
  field :last_recorded_at, :type => DateTime
  field :notify_on_next_occurrence, :type => Boolean, :default => true
  
  has_many :events, :class_name => "Whoops::Event"
  
  validates_presence_of :identifier, :event_type, :service, :message
  
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
  
  
end