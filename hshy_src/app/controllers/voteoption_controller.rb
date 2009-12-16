class VoteoptionController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @voteoption_pages, @voteoptions = paginate :voteoptions, :per_page => 40, :conditions=>"vote_id = #{params[:id]}"
    render :layout=>false
  end

  def show
    @voteoption = Voteoption.find(params[:id])
  end

  def new
    @voteoption = Voteoption.new
    @voteoption.vote_id = params[:id] if params[:id]
    render :layout=>false
  end

  def create
    @voteoption = Voteoption.new(params[:voteoption])
    @voteoption.name = EncodeUtil.change("GB2312", "UTF-8", @voteoption.name)
    if @voteoption.save
      redirect_to :action => 'list', :id=>params[:id]
    else
      render :action => 'new'
    end
  end

  def edit
    @voteoption = Voteoption.find(params[:id])
  end

  def update
    @voteoption = Voteoption.find(params[:id])
    if @voteoption.update_attributes(params[:voteoption])
      flash[:notice] = 'Voteoption was successfully updated.'
      redirect_to :action => 'show', :id => @voteoption
    else
      render :action => 'edit'
    end
  end

  def destroy
    option = Voteoption.find(params[:id])
    redirect_to :controller=>"vote", :action => 'list'
    option.destroy
  end
end
