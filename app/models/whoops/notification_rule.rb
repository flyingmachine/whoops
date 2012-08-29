class Whoops::NotificationRule
  include Mongoid::Document
  
  field :email, :type => String
  field :matchers, :type => Array

  validates_presence_of :email

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
    write_attribute(:matchers, split_matchers(matchers).sort)
  end

  def add_matchers(new_matchers)
    split = split_matchers(new_matchers)
    write_attribute(:matchers, (self.matchers | split).sort)
    self.save
  end

  def split_matchers(new_matchers)
    new_matchers.split("\n").collect{ |m| m.strip }
  end

  def self.add_rules(params)
    params[:email] = params[:email].downcase
    if rule = first(:conditions => {:email => params[:email]})
      rule.add_matchers(params[:matchers])
    else
      create(params)
    end
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
      service_matches = event_group.service.split(".").inject([]){|collection, part| collection << [collection.last, part].compact.join(".")}.join("|")
      @matches ||= Whoops::NotificationRule.where(:matchers => /^((#{service_matches})\S*$|(#{service_matches}).*#{event_group.environment})/)
    end
  end
end
