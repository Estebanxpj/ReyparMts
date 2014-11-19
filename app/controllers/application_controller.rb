
  class ApplicationController < ActionController::Base
    
    before_filter :login_required
    
    rescue_from ActiveRecord::DeleteRestrictionError do |e|
      redirect_to request.referer || root_path, :alert => e.message
    end
    
    #rescue_from Commitbox::Error do |e|
     # @exception = e
     # render :layout => 'sub', :template => 'shared/error'
    #end

    private

    def login_required
      unless logged_in?
        redirect_to login_path
      end
    end

    def logged_in?
      current_user.is_a?(User)
    end
    
    def current_user
      @current_user ||= login_from_session || login_with_demo_mdoe || :false
    end

    def login_from_session
      if session[:user_id]
        @user = User.find_by_id(session[:user_id])
      end
    end
    
    def login_with_demo_mdoe
      #if settings.demo_mode?
        @user = User.first
      #end
    end
    
    helper_method :current_user, :logged_in?
    
  end



