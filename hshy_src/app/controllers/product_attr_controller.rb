class ProductAttrController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @product_attr_pages, @product_attrs = paginate :product_attrs, :per_page => 10
  end

  def show
    @product_attr = ProductAttr.find(params[:id])
  end

  def new
    @product_attr = ProductAttr.new
  end

  def create
    @product_attr = ProductAttr.new(params[:product_attr])
    if @product_attr.save
      flash[:notice] = 'ProductAttr was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @product_attr = ProductAttr.find(params[:id])
  end

  def update
    @product_attr = ProductAttr.find(params[:id])
    if @product_attr.update_attributes(params[:product_attr])
      flash[:notice] = 'ProductAttr was successfully updated.'
      redirect_to :action => 'show', :id => @product_attr
    else
      render :action => 'edit'
    end
  end

  def destroy
    ProductAttr.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
