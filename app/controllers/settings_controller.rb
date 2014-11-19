  class SettingsController < ApplicationController
    
    before_filter { @active_nav = :settings }
    
    def update
      if settings.demo_mode?
        raise Error, "You cannot make changes to settings in demo mode. Sorry about that."
      end
      
      Setting.update_from_hash(params[:settings].permit!)
      redirect_to :settings, :notice => "Settings have been updated successfully."
    end
    
  end