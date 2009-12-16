class LogfilterController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @logfilters = Logfilter.paginate :page=>params[:page], :per_page => 20, :order=>"id desc"
  end

  def show
    @logfilter = Logfilter.find(params[:id])
  end

  def new
    @logfilter = Logfilter.new
  end

  def create
    @logfilter = Logfilter.new(params[:logfilter])
    if @logfilter.save
      flash[:notice] = '添加日志过滤成功'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @logfilter = Logfilter.find(params[:id])
  end

  def update
    @logfilter = Logfilter.find(params[:id])
    if @logfilter.update_attributes(params[:logfilter])
      flash[:notice] = '更新日志过滤成功.'
      redirect_to :action => 'list'
    else
      render :action => 'edit'
    end
  end

  def destroy
    Logfilter.find(params[:id]).destroy
    flash[:notice] = '删除日志过滤成功.'
    
    redirect_to :action => 'list'
  end
end
