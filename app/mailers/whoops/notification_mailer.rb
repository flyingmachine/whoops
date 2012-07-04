class Whoops::NotificationMailer < ActionMailer::Base
  def event_notification(event_group, addresses)
    @event_group = event_group
    @addresses = addresses
    mail(
      :to      => addresses.join(", "),
      :from    => Rails.application.config.whoops_sender,
      :subject => "Whoops Notification | #{event_group.service}: #{event_group.environment}: #{event_group.message}",
      :body    => "#{event_group.service}: #{event_group.environment}: #{event_group.message}"
    )
  end
end
