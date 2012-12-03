class Whoops::NotificationSubscription
  include Mongoid::Document

  has_one :filter, :as => :filterable, :class_name => "Whoops::Filter"
  validates_presence_of :email
  
  field :email, :type => String

  before_save :downcase_email
  
  def downcase_email
    self.email.downcase!
  end

  class Matcher
    attr_accessor :event_group
    
    # @param [ Whoops::EventGroup ]
    def initialize(event_group)
      self.event_group = event_group
    end
    
    def matching_emails
      Whoops::NotificationSubscription.all.select do |ns|
        lookup = Whoops::AuthorizedServiceLookup.new(ns.email)
        ns.filter.matches_event_group?(self.event_group)
      end.collect(&:email)
    end
  end
end
