class VoteUserController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @vote_user_pages, @vote_users = paginate :vote_users, :per_page => 10
  end

  def show
    @vote_user = VoteUser.find(params[:id])
  end

  def new
    @vote_user = VoteUser.new
  end

  def create
    @vote_user = VoteUser.new(params[:vote_user])
    if @vote_user.save
      flash[:notice] = 'VoteUser was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @vote_user = VoteUser.find(params[:id])
  end

  def update
    @vote_user = VoteUser.find(params[:id])
    if @vote_user.update_attributes(params[:vote_user])
      flash[:notice] = 'VoteUser was successfully updated.'
      redirect_to :action => 'show', :id => @vote_user
    else
      render :action => 'edit'
    end
  end

  def destroy
    VoteUser.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
