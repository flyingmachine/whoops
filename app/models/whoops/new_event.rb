# Receives new event params and processes them
class Whoops::NewEvent
  def initialize(params)
    @params = params.with_indifferent_access
  end

  # both records and sends notifications
  def record!
    find_or_build_event_group
    update_event_group_attributes
    send_notifications_for_event_group
    
    @event_group.archived = false
    @event_group.save
    @event_group.events.create(event_params)
    @event_group
  end

  private

  def find_or_build_event_group
    @event_group = Whoops::EventGroup.first(:conditions => event_group_identifying_fields) || Whoops::EventGroup.new(event_group_params)
  end

  def update_event_group_attributes
    if @event_group.valid?
      @event_group.attributes = event_group_params
      @event_group.last_recorded_at = Time.now
      @event_group.event_count += 1
    end
  end

  def should_send_notifications?
    @event_group.valid? && (!@event_group.archived? || @event_group.new_record?) && Rails.application.config.whoops_sender.present?
  end

  def send_notifications_for_event_group
    return unless should_send_notifications?
    matcher = Whoops::NotificationSubscription::Matcher.new(@event_group)
    Whoops::NotificationMailer.event_notification(@event_group, matcher.matching_emails).deliver unless matcher.matching_emails.empty?
  end

  # TODO does it make sense to have a separate params object?
  def event_group_params
    @params.slice(*Whoops::EventGroup.field_names)
  end

  def event_group_identifying_fields
    @params.slice(*Whoops::EventGroup.identifying_fields)
  end

  def event_params
    @params.slice(*Whoops::Event.field_names)
  end
end
