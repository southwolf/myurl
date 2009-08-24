class SitesController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    if params[:id]
      @sites = Site.paginate :page=>params[:page], :per_page => 10,:conditions=>"label_id=#{params[:id]}"
    else
      @sites = Site.paginate :page=>params[:page], :per_page => 10
    end
  end

  def show
    @site = Site.find(params[:id])
  end

  def new
    @site = Site.new
    @site.label_id = params[:id] || 1
  end

  def create
    @site = Site.new(params[:site])
    if @site.save
      flash[:notice] = '添加站点成功.'
      redirect_to :action => 'list', :id=>@site.label_id
    else
      render :action => 'new'
    end
  end

  def edit
    @site = Site.find(params[:id])
  end

  def update
    @site = Site.find(params[:id])
    if @site.update_attributes(params[:site])
      flash[:notice] = 'Site was successfully updated.'
      redirect_to :action => 'show', :id => @site
    else
      render :action => 'edit'
    end
  end

  def destroy
    Site.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
