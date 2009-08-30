class JokesController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @joke_pages, @jokes = paginate :jokes, :per_page => 10
  end

  def show
    @joke = Joke.find(params[:id])
  end

  def new
    @joke = Joke.new
  end

  def create
    @joke = Joke.new(params[:joke])
    if @joke.save
      flash[:notice] = 'Joke was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @joke = Joke.find(params[:id])
  end

  def update
    @joke = Joke.find(params[:id])
    if @joke.update_attributes(params[:joke])
      flash[:notice] = 'Joke was successfully updated.'
      redirect_to :action => 'show', :id => @joke
    else
      render :action => 'edit'
    end
  end

  def destroy
    Joke.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
