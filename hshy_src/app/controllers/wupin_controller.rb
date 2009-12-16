class WupinController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @wupin_pages, @wupins = paginate :wupins, :per_page => 10
  end

  def show
    @wupin = Wupin.find(params[:id])
  end

  def new
    @wupin = Wupin.new
  end

  def create
    @wupin = Wupin.new(params[:wupin])
    if @wupin.save
      flash[:notice] = 'Wupin was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @wupin = Wupin.find(params[:id])
  end

  def update
    @wupin = Wupin.find(params[:id])
    if @wupin.update_attributes(params[:wupin])
      flash[:notice] = 'Wupin was successfully updated.'
      redirect_to :action => 'show', :id => @wupin
    else
      render :action => 'edit'
    end
  end

  def destroy
    Wupin.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
