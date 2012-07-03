class NotificationRulesController < ApplicationController
  layout 'whoops'

  def index
    @notification_rule = Whoops::NotificationRule.new
    @notification_rules = Whoops::NotificationRule.asc(:email)
  end

  def create
    Whoops::NotificationRule.add_rules(params[:notification_rule])
    redirect_to whoops_notification_rules_path
  end

  def edit
    @notification_rule = Whoops::NotificationRule.find(params[:id])
  end

  def update
    @notification_rule = Whoops::NotificationRule.find(params[:id])
    @notification_rule.update_attributes(params[:notification_rule])
    notification_rules = Whoops::NotificationRule.asc(:email)
    redirect_to whoops_notification_rules_path
  end

  def destroy
    Whoops::NotificationRule.find(params[:id]).destroy
    redirect_to whoops_notification_rules_path
  end
end
