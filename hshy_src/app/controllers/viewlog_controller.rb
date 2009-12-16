class ViewlogController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @viewlog_pages, @viewlogs = paginate :viewlogs, :per_page => 10
  end

  def show
    @viewlog = Viewlog.find(params[:id])
  end

  def new
    @viewlog = Viewlog.new
  end

  def create
    @viewlog = Viewlog.new(params[:viewlog])
    if @viewlog.save
      flash[:notice] = 'Viewlog was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @viewlog = Viewlog.find(params[:id])
  end

  def update
    @viewlog = Viewlog.find(params[:id])
    if @viewlog.update_attributes(params[:viewlog])
      flash[:notice] = 'Viewlog was successfully updated.'
      redirect_to :action => 'show', :id => @viewlog
    else
      render :action => 'edit'
    end
  end

  def destroy
    Viewlog.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
