class RighttypeController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @righttype_pages, @righttypes = paginate :righttypes, :per_page => 10
  end

  def show
    @righttype = Righttype.find(params[:id])
  end

  def new
    @righttype = Righttype.new
  end

  def create
    @righttype = Righttype.new(params[:righttype])
    if @righttype.save
      flash[:notice] = '添加权限种类成功'
      redirect_to :controller=>"ytwg_right", :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @righttype = Righttype.find(params[:id])
  end

  def update
    @righttype = Righttype.find(params[:id])
    if @righttype.update_attributes(params[:righttype])
      flash[:notice] = 'Righttype was successfully updated.'
      redirect_to :action => 'show', :id => @righttype
    else
      render :action => 'edit'
    end
  end

  def destroy
    Righttype.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
