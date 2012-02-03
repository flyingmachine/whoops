class Whoops::Filter
  include Mongoid::Document
  include FieldNames
  
  [:service, :environment, :event_type, :message, :details].each do |document_field|
    field document_field, :type => Array
  end
    
  def to_query_document
    doc = attributes.except(:_id, "_id").delete_if{|k, v| v.blank?}
    # match all services under namespace. ie, if "app" given, match "app.web", "app.backend" etc
    doc["service"] = doc["service"].collect{ |d| /^#{d}/ } if doc["service"]
    doc.inject({}) do |hash, current|
      hash[current.first.to_sym.in] = current.last unless current.last.empty?
      hash
    end
  end

  class << self
    def new_from_params(params)
      if params
        new(params.inject({}){|hash, current| hash[current.first] = current.last.keys; hash})
      else
        new
      end
    end
  end   
end
