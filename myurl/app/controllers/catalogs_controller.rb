class CatalogsController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @catalogs = Catalog.paginate :page=>params[:page], :per_page => 20, :order=>"id desc", :conditions=>"user_id=#{session[:user].id}"
    @catalog = Catalog.find(params[:id]) if params[:id]
  end

  def show
    @catalogs = Catalogs.find(params[:id])
  end

  def new
    @catalogs = Catalog.new
  end

  def create
    @catalog = Catalog.new(params[:new_catalog])
    @catalog.user_id = session[:user].id
    @catalog.parent_id = params[:parent_id] if params[:parent_id]
    if @catalog.save
      flash[:notice] = '创建分类成功'
      redirect_to :action => 'list', :id=>@catalog
    else
      render :action => 'new'
    end
  end

  def edit
    @catalogs = Catalogs.find(params[:id])
  end

  def update
    @catalog = Catalog.find(params[:id])
    if @catalog.update_attributes(params[:catalog])
      flash[:notice] = '修改分类成功'
      redirect_to :action => 'list', :id => @catalog.id
    else
      render :action => 'edit'
    end
  end

  def destroy
    Catalog.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
