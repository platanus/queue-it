class QueueIt::InstallGenerator < Rails::Generators::Base
  source_root File.expand_path('templates', __dir__)

  def create_initializer
    template "initializer.rb", "config/initializers/queue_it.rb"
  end

  def mount_routes
    line = "Rails.application.routes.draw do\n"
    inject_into_file "config/routes.rb", after: line do <<-"HERE".gsub(/^ {4}/, '')
      mount QueueIt::Engine => "/queue_it"
    HERE
    end
  end

  def copy_engine_migrations
    rake "queue_it:install:migrations"
  end
end
