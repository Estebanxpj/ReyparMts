class ClientsController < ApplicationController

	    before_filter { @active_nav = :client }
    before_filter { params[:id] && @client = Client.find(params[:id]) }

    def index
        #@query = Shoppe::Client.all
        @clients = Client.search(params[:nit])
    end

    def search
      index
      render :action => "index"
    end

    def show
    end
    
    private
  
    def safe_params
      params[:client].permit(:first_name, :last_name, :email_address, :nit, :company, :billing_address1, :billing_postcode, :phone_number)
    end
end
