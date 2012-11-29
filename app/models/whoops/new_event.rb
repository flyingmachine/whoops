class Whoops::NewEvent
  def initialize(params)
    @params = params.with_indifferent_access
  end

  def record!
    event_group = find_or_build_event_group
    update_event_group_attributes(event_group)
    send_notifications_for_event_group(event_group)
    save_event_group(event_group)
    event_group.events.create(@params.slice(*Whoops::Event.field_names))
    event_group
  end

  def find_or_build_event_group
    Whoops::EventGroup.first(:conditions => @params.slice(*Whoops::EventGroup.identifying_fields)) || Whoops::EventGroup.new(event_group_params)
  end

  def update_event_group_attributes(event_group)
    if event_group.valid?
      event_group.attributes = event_group_params
      event_group.last_recorded_at = Time.now
      event_group.event_count += 1
    end
  end

  def save_event_group(event_group)
    event_group.archived = false
    event_group.save
  end

  def should_send_notifications?(event_group)
    event_group.valid? && (event_group.archived || event_group.new_record) && Rails.application.config.whoops_sender
  end

  def send_notifications_for_event_group(event_group)
    return unless should_send_notifications?(event_group)
    matcher = Whoops::NotificationSubscription::Matcher.new(event_group)
    Whoops::NotificationMailer.event_notification(event_group, matcher.matching_emails).deliver unless matcher.matching_emails.empty?
  end

  def event_group_params
    @params.slice(*Whoops::EventGroup.field_names)
  end
end
