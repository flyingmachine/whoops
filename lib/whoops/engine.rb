module Whoops
  class Engine < Rails::Engine
    initializer "static assets" do |app|
      app.middleware.use ::ActionDispatch::Static, File.expand_path("../../../app/assets/javascripts", __FILE__)
    end

    initializer "default whoops sender", :before => :load_config_initializers do |app|
      begin
        app.config.whoops_sender ||= nil
      rescue NoMethodError
        app.config.whoops_sender = nil
      end
    end
  end
end
