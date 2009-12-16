class SfcjGjController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @sfcj_gjs = SfcjGj.find(:all, :conditions=>"sfcj_id=#{params[:id]}")
    render :layout=>false
  end

  def show
    @sfcj_gj = SfcjGj.find(params[:id])
  end

  def new
    @sfcj_gj = SfcjGj.new
    
  end

  def create
    @sfcj_gj = SfcjGj.new(params[:sfcj_gj])
    @sfcj_gj.sfcj_id = params[:id]
    @sfcj_gj.publisher=session[:user].truename
    @sfcj_gj.publish_time = Time.new
    if @sfcj_gj.save
      flash[:notice] = '添加跟进成功'
      redirect_to :controller=>"sfcj", :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @sfcj_gj = SfcjGj.find(params[:id])
  end

  def update
    @sfcj_gj = SfcjGj.find(params[:id])
    if @sfcj_gj.update_attributes(params[:sfcj_gj])
      flash[:notice] = 'SfcjGj was successfully updated.'
      redirect_to :action => 'show', :id => @sfcj_gj
    else
      render :action => 'edit'
    end
  end

  def destroy
    SfcjGj.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
