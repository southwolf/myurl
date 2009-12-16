class FilestockController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @filestocks = Filestock.paginate :page=>params[:page], :per_page => 20, :order=>" id desc", :conditions=>"user_id = #{session[:user].id}"
  end

  def show
    @filestock = Filestock.find(params[:id])
  end

  def new
    @filestock = Filestock.new
  end

  def create
    @filestock = Filestock.new(params[:filestock])
    @filestock.user_id = session[:user].id
    @filestock.publish_time = Time.new
    
    if !@filestock.path
      flash[:notice] = '请选择一个文件.'
      render :action=>"new"
      return
    end
    
    if @filestock.save
      flash[:notice] = '文件上传成功.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @filestock = Filestock.find(params[:id])
  end

  def update
    @filestock = Filestock.find(params[:id])
    if @filestock.update_attributes(params[:filestock])
      flash[:notice] = 'Filestock was successfully updated.'
      redirect_to :action => 'show', :id => @filestock
    else
      render :action => 'edit'
    end
  end

  def destroy
    Filestock.find(params[:id]).destroy
    flash[:notice] = '文件删除成功'
    redirect_to :action => 'list'
  end
end
