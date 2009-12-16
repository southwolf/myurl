class DicDizhiController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @dic_dizhis = DicDizhi.paginate :page=>params[:page], :per_page => 10
  end

  def show
    @dic_dizhi = DicDizhi.find(params[:id])
  end

  def new
    @dic_dizhi = DicDizhi.new
  end

  def create
    @dic_dizhi = DicDizhi.new(params[:dic_dizhi])
    if @dic_dizhi.save
      flash[:notice] = '添加地址成功'
      redirect_to :controller=>"quyu", :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @dic_dizhi = DicDizhi.find(params[:id])
  end

  def update
    @dic_dizhi = DicDizhi.find(params[:id])
    if @dic_dizhi.update_attributes(params[:dic_dizhi])
      flash[:notice] = '修改地址成功'
      redirect_to :controller=>"quyu", :action => 'list', :id => @dic_dizhi
    else
      render :action => 'edit'
    end
  end

  def destroy
    DicDizhi.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
