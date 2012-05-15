class Whoops::Event
  include Mongoid::Document
  include FieldNames
  
  belongs_to :event_group, :class_name => "Whoops::EventGroup", :index=>true
  
  field :details
  field :keywords, :type => String
  field :message, :type => String
  field :event_time, :type => DateTime

  index([[:event_group_id,Mongo::ASCENDING],[:event_time, Mongo::DESCENDING]])

  validates_presence_of :message  
  
  before_save :set_keywords, :sanitize_details
  
  def self.record(params)
    params = params.with_indifferent_access
    
    event_group_params                    = params.slice(*Whoops::EventGroup.field_names)
    event_group_params[:last_recorded_at] = params[:event_time]
    event_group_params
    event_group = Whoops::EventGroup.handle_new_event(event_group_params)
    
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
  
  def sanitize_details
    if details.is_a? Hash
      sanitized_details = {}
      details.each do |key, value|
        if key =~ /\./
          key = key.gsub(/\./, "_")
        end
        
        if value.is_a? Hash
          child_keys = all_keys([value])
          if child_keys.any?{ |child_key| child_key =~ /\./ } 
            value = value.to_s
          end
        end
        
        sanitized_details[key] = value
      end
      
      self.details = sanitized_details
    end
  end
  
  def all_keys(values)
    keys = []
    values.each do |value|
      if value.is_a? Hash
        keys |= value.keys
        keys |= all_keys(value.values)
      end
    end
    keys
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
