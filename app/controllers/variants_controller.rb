 class VariantsController < ApplicationController
    
    before_filter { @active_nav = :products }
    before_filter { @product = Product.find(params[:product_id]) }
    before_filter { params[:id] && @variant = @product.variants.find(params[:id]) }
    
    def index
      @variants = @product.variants.ordered
    end
    
    def new
      @variant = @product.variants.build
      render :action => "form"
    end
    
    def create
      @variant = @product.variants.build(safe_params)
      if @variant.save
        redirect_to [@product, :variants], :notice => "Varient has been added successfully"
      else
        render :action => "form"
      end
    end
    
    def edit
      render :action => "form"
    end
    
    def update
      if @variant.update(safe_params)
        redirect_to edit_product_variant_path(@product, @variant), :notice => "Varient has been updated successfully"
      else
        render :action => "form"
      end
    end
    
    def destroy
      @variant.destroy
      redirect_to [@product, :variants], :notice => "Varient has been removed successfully"
    end
    
    private
    
    def safe_params
      params[:product].permit(:name, :permalink, :sku, :default_image_file, :price, :cost_price, :tax_rate_id, :weight, :stock_control, :active, :default)
    end
    
  end
