class MessagesController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @message_pages, @messages = paginate :messages, :per_page => 10
  end

  def show
    @message = Message.find(params[:id])
  end

  def new
    @message = Message.new
  end

  def create
    @message = Message.new(params[:message])
    if @message.save
      flash[:notice] = 'Message was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @message = Message.find(params[:id])
  end

  def update
    @message = Message.find(params[:id])
    if @message.update_attributes(params[:message])
      flash[:notice] = 'Message was successfully updated.'
      redirect_to :action => 'show', :id => @message
    else
      render :action => 'edit'
    end
  end

  def destroy
    Message.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
