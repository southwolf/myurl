class ProjectprogressController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
   @projectprogresses =Projectprogress.find(:all, :conditions=>"project_id = #{params[:id]}")
  end

  def show
    @projectprogress = Projectprogress.find(params[:id])
  end

  def new
    @projectprogress = Projectprogress.new
  end

  def create
    @projectprogress = Projectprogress.new(params[:projectprogress])
    @projectprogress.project_id = params[:id]
    @projectprogress.publisher = session[:user].truename
    if @projectprogress.save
      flash[:notice] = '添加项目进度成功.'
      redirect_to :action => 'list', :id=>params[:id]
    else
      render :action => 'new'
    end
  end

  def edit
    @projectprogress = Projectprogress.find(params[:id])
  end

  def update
    @projectprogress = Projectprogress.find(params[:id])
    
    if @projectprogress.update_attributes(params[:projectprogress])
      flash[:notice] = 'Projectprogress was successfully updated.'
      redirect_to :action => 'show', :id => @projectprogress
    else
      render :action => 'edit'
    end
  end

  def destroy
    p = Projectprogress.find(params[:id])
    flash[:notice] = "删除进度成功"
    redirect_to :action => 'list', :id=>p.project_id
    p.destroy
  end
end
