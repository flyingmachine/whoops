module Whoops
  class Engine < Rails::Engine
    initializer "static assets" do |app|
      app.middleware.use ::ActionDispatch::Static, File.expand_path("../../../app/assets/javascripts", __FILE__)
    end

    initializer "default whoops sender", :before => :load_config_initializers do |app|
      app.config.whoops_sender ||= nil
    end
  end
end
