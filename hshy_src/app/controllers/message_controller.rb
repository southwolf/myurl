class MessageController < ApplicationController
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
  
  def mymessage
    Message.update_all "isread=1", "to_id = #{session[:user].id}"
    messages = Message.find :all, :conditions=>"from_id=#{session[:user].id} or to_id = #{session[:user].id}", :order=>"id desc", :limit=>40
    render :partial=>"share/message_detail", :locals=>{:messages=>messages}
  end

  def show
    @message = Message.find(params[:id])
  end

  def new
    @message = Message.new
  end

  def create
    params[:message][:text] = EncodeUtil.change("GB2312", "UTF-8", params[:message][:text])
    message = Message.new(params[:message])
    message.from_id = session[:user].id
    if message.save
      #redirect_to :action => 'list'
      messages = Message.find(:all, :conditions=>"to_id = #{session[:user].id} or from_id=#{session[:user].id}", :order=>"id desc")
      render :partial=>"share/message_detail", :locals=>{:messages=>messages}
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
