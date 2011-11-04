class Whoops::NotificationRule
  include Mongoid::Document
  
  field :email, :type => String
  field :matchers, :type => Array

  # This might come in handy in the future?
  # class << self.fields["matchers"]
  #   def set(object)
  #     object = object.split("\n").collect{ |m| m.strip } if object.is_a?(String)
  #     object
  #   end
  # end
  
  before_save :downcase_email
  
  def downcase_email
    self.email.downcase!
  end
  
  def matchers=(matchers)
    write_attribute(:matchers, matchers.split("\n").collect{ |m| m.strip })
  end
  
  def self.matches(event)
    
  end
  
  class Matcher
    attr_accessor :event_group
    
    # @param [ Whoops::EventGroup ]
    def initialize(event_group)
      self.event_group = event_group
    end
    
    def matching_emails
      matches.collect{|m| m.email}.uniq
    end
    
    def matches
      @matches ||= Whoops::NotificationRule.where(:matchers => /^#{event_group.service}/)
    end
  end
end