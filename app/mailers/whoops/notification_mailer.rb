class Whoops::NotificationMailer < ActionMailer::Base
  def event_notification(event_group, addresses)
    @event_group = event_group
    @addresses = addresses
    body = <<-BODY
#{whoops_event_group_events_url(event_group.id)}

#{event_group.service}: #{event_group.environment}: #{event_group.message}
    BODY
    mail(
      :to      => addresses.join(", "),
      :from    => Rails.application.config.whoops_sender,
      :subject => "Whoops Notification | #{event_group.service}: #{event_group.environment}: #{event_group.message}",
      :body    => body,
      :content_type => "text/plain"
    )
  end
end
