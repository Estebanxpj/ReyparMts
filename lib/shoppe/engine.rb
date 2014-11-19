  class Engine < ::Rails::Engine
    isolate_namespace commitbox
    
    if respond_to?(:root)
      config.autoload_paths << File.join(root, 'lib')
      config.assets.precompile += ['sub.css', 'printable.css']
    end
    
    # We don't want any automatic generators in the engine.
    config.generators do |g|
      g.orm             :active_record
      g.test_framework  false
      g.stylesheets     false
      g.javascripts     false
      g.helper          false
    end
    
    initializer 'initialize' do |app|
      # Add the default settings
      add_settings_group :system_settings, [:store_name, :email_address, :currency_unit, :tax_name, :demo_mode]
      
      # Add middleware
      app.config.middleware.use SettingsLoader
      
      # Load our migrations into the application's db/migrate path
      unless app.root.to_s.match root.to_s
        config.paths["db/migrate"].expanded.each do |expanded_path|
          app.config.paths["db/migrate"] << expanded_path
        end
      end      
      
      # Load view helpers for the base application
      ActiveSupport.on_load(:action_view) do
        require 'view_helpers'
        ActionView::Base.send :include, ViewHelpers
      end
      
      # Load default navigation
      require 'default_navigation'
    end
    
    generators do
      require 'setup_generator'
    end
    
  end
end

