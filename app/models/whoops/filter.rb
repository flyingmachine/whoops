class Whoops::Filter
  include Mongoid::Document
  include FieldNames
  
  [:service, :environment, :event_type, :message, :details].each do |document_field|
    field document_field
  end
    
  def to_query_document
    doc = attributes.except(:_id).delete_if{|k, v| v.blank?}
    # match all services under namespace. ie, if "app" given, match "app.web", "app.backend" etc
    doc[:service] = /#{doc[:service]}(\..*)?/ if doc[:service]
    doc
  end
end
