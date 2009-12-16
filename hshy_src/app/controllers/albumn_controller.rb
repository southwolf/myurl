class AlbumnController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @albumns = Albumn.paginate :page=>params[:page], :per_page => 10, :order=>"id desc"
  end

  def show
    @albumn = Albumn.find(params[:id])
  end

  def new
    @albumn = Albumn.new
  end

  def create
    @albumn = Albumn.new(params[:album])
    @albumn.user_id = session[:user].id
    @albumn.made_time = Time.new
    if @albumn.save
      flash[:notice] = '添加相册成功'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @albumn = Albumn.find(params[:id])
  end

  def update
    @albumn = Albumn.find(params[:id])
    if @albumn.update_attributes(params[:album])
      flash[:notice] = 'Album was successfully updated.'
      redirect_to :action => 'show', :id => @albumn
    else
      render :action => 'edit'
    end
  end

  def destroy
    Albumn.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
