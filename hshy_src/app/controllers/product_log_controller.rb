class ProductLogController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @product_logs = ProductLog.find(:all, :conditions=>"product_id = #{params[:id]}")
    @product = Product.find(params[:id])
  end

  def show
    @product_log = ProductLog.find(params[:id])
  end

  def new
    @product_log = ProductLog.new
  end

  def create
    @product_log = ProductLog.new(params[:product_log])
    if @product_log.save
      flash[:notice] = 'ProductLog was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @product_log = ProductLog.find(params[:id])
  end

  def update
    @product_log = ProductLog.find(params[:id])
    if @product_log.update_attributes(params[:product_log])
      flash[:notice] = 'ProductLog was successfully updated.'
      redirect_to :action => 'show', :id => @product_log
    else
      render :action => 'edit'
    end
  end

  def destroy
    ProductLog.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
