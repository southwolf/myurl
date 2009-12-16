class YtwgGroupController < ApplicationController
  #$title = '组管理'
  def index
    list
    render :action => 'list'
  end
  
  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
   # @ytwg_group_pages, @ytwg_groups = paginate :ytwg_groups, :per_page => 20 , :order=>params[:order]
    @ytwg_groups = YtwgGroup.paginate :page=>params[:page], :per_page => 20 , :order=>params[:order]
  end

  def show
    @ytwg_group = YtwgGroup.find(params[:id])
  end

  def new
    @ytwg_group = YtwgGroup.new
  end

  def create
    @ytwg_group = YtwgGroup.new(params[:ytwg_group])
    if @ytwg_group.save
      flash[:notice] = '新建组成功'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end


  def edit
    @ytwg_group = YtwgGroup.find(params[:id])
  end

  def update
    @ytwg_group = YtwgGroup.find(params[:id])
    if @ytwg_group.update_attributes(params[:ytwg_group])
      flash[:notice] = '修改权限成功'
      redirect_to :action => 'list'
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    YtwgGroup.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

  
end
