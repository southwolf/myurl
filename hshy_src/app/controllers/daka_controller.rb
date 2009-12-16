class DakaController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @daka_pages, @dakas = paginate :dakas, :per_page => 10
  end

  def show
    @daka = Daka.find(params[:id])
  end

  def new
    @daka = Daka.new
  end

  def create
    @daka = Daka.new(params[:daka])
    if @daka.save
      flash[:notice] = 'Daka was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @daka = Daka.find(params[:id])
  end

  def update
    @daka = Daka.find(params[:id])
    if @daka.update_attributes(params[:daka])
      flash[:notice] = 'Daka was successfully updated.'
      redirect_to :action => 'show', :id => @daka
    else
      render :action => 'edit'
    end
  end

  def destroy
    Daka.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
