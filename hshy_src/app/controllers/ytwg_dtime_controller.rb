class YtwgDtimeController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @ytwg_dtime_pages, @ytwg_dtimes = paginate :ytwg_dtimes, :per_page => 10
  end

  def show
    @ytwg_dtime = YtwgDtime.find(params[:id])
  end

  def new
    @ytwg_dtime = YtwgDtime.new
  end

  def create
    @ytwg_dtime = YtwgDtime.new(params[:ytwg_dtime])
    if @ytwg_dtime.save
      flash[:notice] = 'YtwgDtime was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @ytwg_dtime = YtwgDtime.find(params[:id])
  end

  def update
    @ytwg_dtime = YtwgDtime.find(params[:id])
    if @ytwg_dtime.update_attributes(params[:ytwg_dtime])
      flash[:notice] = 'YtwgDtime was successfully updated.'
      redirect_to :action => 'show', :id => @ytwg_dtime
    else
      render :action => 'edit'
    end
  end

  def destroy
    YtwgDtime.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
