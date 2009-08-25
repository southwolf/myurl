class HotsController < ApplicationController
  before_filter :login_required
  
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @hot = Hot.new
    @hot.address = "http://"
    @hots = Hot.paginate :page=>params[:page], :per_page => 10, :order=>"id desc", :conditions=>"user_id=#{session[:user].id}"
  end

  def show
    @hot = Hot.find(params[:id])
  end

  def new
    @hot = Hot.new
  end

  def create
    @hot = Hot.new(params[:hot])
    @hot.user_id = session[:user].id
    if @hot.save
      flash[:notice] = '添加常用站点成功'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @hot = Hot.find(params[:id])
  end

  def update
    @hot = Hot.find(params[:id])
    if @hot.update_attributes(params[:hot])
      flash[:notice] = '修改站点成功'
      redirect_to :action => 'list'
    else
      render :action => 'edit'
    end
  end

  def destroy
    Hot.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
