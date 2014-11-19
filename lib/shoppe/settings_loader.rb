  class SettingsLoader
    
    def initialize(app)
      @app = app
    end
    
    def call(env)
      reset_settings
      @app.call(env)
    ensure
      reset_settings
    end
    
  end
end
