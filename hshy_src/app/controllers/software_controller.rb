class SoftwareController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @softwares = Software.paginate :page=>params[:page], :per_page => 10
  end

  def show
    @software = Software.find(params[:id])
  end

  def new
    @software = Software.new
  end

  def create
    @software = Software.new(params[:software])
    @software.publisher = session[:user].truename
    @software.publish_time = Time.new
    if @software.save
      flash[:notice] = '创建系统成功'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @software = Software.find(params[:id])
  end

  def update
    @software = Software.find(params[:id])
    if @software.update_attributes(params[:software])
      flash[:notice] = '修改系统成功'
      redirect_to :action => 'list'
    else
      render :action => 'edit'
    end
  end

  def destroy
    Software.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
