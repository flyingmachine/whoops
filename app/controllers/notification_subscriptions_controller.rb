class NotificationSubscriptionsController < ApplicationController
  layout 'whoops'

  def index
    @notification_subscription = Whoops::NotificationSubscription.new
    @notification_subscription.build_filter
    @notification_subscriptions = Whoops::NotificationSubscription.asc(:email)
    @filter = Whoops::Filter.new
  end

  def create
    ns = Whoops::NotificationSubscription.create(params[:notification_subscription])
    ns.filter = Whoops::Filter.new_from_params(params[:whoops_filter])
    ns.filter.save
    redirect_to whoops_notification_subscriptions_path
  end

  def edit
    @notification_subscription = Whoops::NotificationSubscription.find(params[:id])
  end

  def update
    @notification_subscription = Whoops::NotificationSubscription.find(params[:id])
    @notification_subscription.update_attributes(params[:notification_subscription])
    @notification_subscription.filter.update_from_params(params[:whoops_filter])
    redirect_to whoops_notification_subscriptions_path
  end

  def destroy
    Whoops::NotificationSubscription.find(params[:id]).destroy
    redirect_to whoops_notification_subscriptions_path
  end
end
