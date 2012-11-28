class Whoops::Filter
  include Mongoid::Document
  include FieldNames

  FILTERED_FIELDS = [:service, :environment, :event_type, :message, :details]
  
  FILTERED_FIELDS.each do |document_field|
    field document_field, :type => Array
  end

  belongs_to :filterable, :polymorphic => true
    
  def to_query_document
    doc = attributes.except(:_id, "_id").delete_if{|k, v| v.blank?}
    # match all services under namespace. ie, if "app" given, match "app.web", "app.backend" etc
    doc["service"] = doc["service"].collect{ |d| /^#{d}/ } if doc["service"]
    doc.inject({}) do |hash, current|
      hash[current.first.to_sym.in] = current.last unless current.last.empty?
      hash
    end
  end

  def matches_event_group?(event_group)
    FILTERED_FIELDS.all? do |field|
      if self.send(field).blank?
        true
      else
        /^(#{self.send(field).join("|")})$/ =~ event_group.send(field)
      end
    end
  end

  class << self
    def new_from_params(params)
      if params
        f = new(params.inject({}){ |hash, current|
            allowed_values = current.last.keys
            hash[current.first] = allowed_values.include?("all") ? [] : allowed_values
            hash
          })
      else
        new
      end
    end
  end   
end
