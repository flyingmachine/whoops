require 'rails/generators'

module Whoops
  class AssetsGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)
    desc 'Installs assets into your public directory.'
    
    def install_assets
      directory 'assets', 'public/'
    end
      
    def self.source_root
       @source_root ||= File.join(File.dirname(__FILE__), 'templates')
    end
  end
end