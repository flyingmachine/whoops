require 'rails/generators'

module Whoops
  class AssetsGenerator < Rails::Generators::Base
    source_root File.expand_path('../../../../app', __FILE__)
    desc 'Installs assets into your public directory.'

    def install_assets
      directory 'assets', 'public/'
    end

    def self.source_root
      @source_root ||= File.expand_path('../../../../app', __FILE__)
    end
  end
end
