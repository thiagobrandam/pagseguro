module PagSeguro
  class Railtie < Rails::Railtie
    generators do
      require "pag_seguro/generator"
    end

    initializer :add_routing_paths do |app|
      if PagSeguro.developer?
        app.routes_reloader.paths.unshift(File.dirname(__FILE__) + "/routes.rb")
      end
    end

    rake_tasks do
      load File.dirname(__FILE__) + "/../tasks/pag_seguro.rake"
    end

    initializer "pag_seguro.initialize" do |app|
      ::ActionView::Base.send(:include, PagSeguro::Helper)
      ::ActionController::Base.send(:include, PagSeguro::ActionController)
    end

    config.after_initialize do
      require "pag_seguro/developer_controller" if PagSeguro.developer?
    end
  end
end

