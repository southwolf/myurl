class DatachannelController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @datachannel_pages, @datachannels = paginate :datachannels, :per_page => 10
  end

  def show
    @datachannel = Datachannel.find(params[:id])
  end

  def new
    @datachannel = Datachannel.new
  end

  def create
    @datachannel = Datachannel.new(params[:datachannel])
    if @datachannel.save
      flash[:notice] = 'Datachannel was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @datachannel = Datachannel.find(params[:id])
  end

  def update
    @datachannel = Datachannel.find(params[:id])
    if @datachannel.update_attributes(params[:datachannel])
      flash[:notice] = 'Datachannel was successfully updated.'
      redirect_to :action => 'show', :id => @datachannel
    else
      render :action => 'edit'
    end
  end

  def destroy
    Datachannel.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
