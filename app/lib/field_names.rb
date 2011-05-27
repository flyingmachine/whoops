module FieldNames
  extend ActiveSupport::Concern
  
  module ClassMethods
    def field_names
      self.fields.keys - ["_id", "_type"]
    end
  end  
end