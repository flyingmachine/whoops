class Whoops::Event
  include Mongoid::Document
  include FieldNames
  
  belongs_to :event_group, :class_name => "Whoops::EventGroup"
  
  field :details
  field :keywords, :type => String
  field :message, :type => String
  field :event_time, :type => DateTime
    
  validates_presence_of :message  
  
  before_save :set_keywords
  
  def self.record(params)
    params = params.with_indifferent_access
        
    event_group_params = params.slice(*Whoops::EventGroup.field_names)
    event_group_params[:identifier] = params[:event_group_identifier]
    event_group_params[:last_recorded_at] = params[:event_time]
    
    event_group = Whoops::EventGroup.first(:conditions => event_group_params.slice(*Whoops::EventGroup.identifying_fields))
    if event_group
      event_group.attributes = event_group_params
      event_group.save
    else
      event_group = Whoops::EventGroup.create(event_group_params)
    end
        
    event_params = params.slice(*Whoops::Event.field_names)
    event_group.events.create(event_params)
  end 
  
  def self.search(query)
    conditions = Whoops::MongoidSearchParser.new(query).conditions
    where(conditions)
  end
  
  def set_keywords
    keywords_array = []
    keywords_array << self.message
    add_details_to_keywords(keywords_array)
    self.keywords = keywords_array.join(" ")
  end
    
  private
  
  def add_details_to_keywords(keywords_array)
    flattened = details.to_a.flatten
    flattened -= details.keys if details.respond_to?(:keys)
    
    until flattened.empty?
      non_hash = flattened.select{ |i| !i.is_a?(Hash) }
      keywords_array.replace(keywords_array | non_hash)
      flattened -= non_hash
      
      flattened.collect! do |i|
        i.to_a.flatten - i.keys
      end.flatten!
    end
    
  end
end