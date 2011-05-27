class Whoops::Event
  include Mongoid::Document
  include FieldNames
  
  belongs_to :event_group, :class_name => "Whoops::EventGroup"
  
  field :details
  field :message, :type => String
  field :event_time, :type => DateTime
  
  validates_presence_of :message
  
  def self.record(params)
    params = params.with_indifferent_access
        
    event_group_params = params.slice(*Whoops::EventGroup.field_names)
    event_group_params[:identifier] = params[:event_group_identifier]
    event_group_params[:last_recorded_at] = params[:event_time]
    
    event_group = Whoops::EventGroup.first(:conditions => event_group_params.slice(*Whoops::EventGroup.identifying_fields))
    event_group ||= Whoops::EventGroup.create(event_group_params)
        
    event_params = params.slice(*Whoops::Event.field_names)
    event_group.events.create(event_params)
  end 
  
end