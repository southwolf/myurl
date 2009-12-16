

class YtwgRightController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @ytwg_rights = YtwgRight.paginate(:order=>"position" ,:per_page => 20, :page => params[:page])
  end

  def show
    @ytwg_right = YtwgRight.find(params[:id])
  end

  def new
    @ytwg_right = YtwgRight.new
  end

  def create
    @ytwg_right = YtwgRight.new(params[:ytwg_right])
    if @ytwg_right.save
      flash[:notice] = '权限添加成功'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @ytwg_right = YtwgRight.find(params[:id])
  end

  def update
    @ytwg_right = YtwgRight.find(params[:id])
    if @ytwg_right.update_attributes(params[:ytwg_right])
      flash[:notice] = '权限修改成功'
      redirect_to :action => 'list'
    else
      render :action => 'edit'
    end
  end

  def destroy
    YtwgRight.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
  
  def reorder
    @rights = YtwgRight.find(:all, :order=>"position")
  end
  
  def order
    index = 1
    for node in params[:nodelist]
      child = YtwgRight.find(node)
      child.position = index
      child.save
      index += 1
    end
    
    render :text=>'排序成功'
  end
  
  
end
