class VoteController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @votes = Vote.paginate :page=>params[:page], :per_page => 10, :order=>"id desc"
  end

  def list_all
    @votes = Vote.find(:all, :order=>"id desc")
  end
  
  def vote
    id = params[:id]
    if !params["vote#{id}"]
      flash[:notice] = "请至少选择一项"
      redirect_to :action=>"list_all"
      return
    end
    
    vote = Vote.find(id)
    user = YtwgUser.find(session[:user].id)
    if user.vote_ids.include?(vote.id)
      flash[:notice] = "您已经投过票了"
    else
      user.votes << vote
      for option in params["vote#{id}"]
        voteoption = Voteoption.find(option)
        voteoption.tickets = voteoption.tickets.to_s.to_i + 1
        voteoption.save
      end
      VoteUser.update_all "choose='#{params["vote#{id}"].join(",")}'", "user_id=#{session[:user].id} and vote_id = #{id}"
    end

    redirect_to :action=>"list_all"
  end
  
  def option
    render :text=>"hello"
  end

  def show
    @vote = Vote.find(params[:id])
    render :layout=>"notoolbar_app"
  end

  def new
    @vote = Vote.new
  end

  def create
    @vote = Vote.new(params[:vote])
    @vote.borndate = Time.new
    if @vote.save
      flash[:notice] = '创建投票成功'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @vote = Vote.find(params[:id])
  end

  def update
    @vote = Vote.find(params[:id])
    if @vote.update_attributes(params[:vote])
      flash[:notice] = '修改投票成功'
      redirect_to :action => 'show', :id => @vote
    else
      render :action => 'edit'
    end
  end

  def destroy
    Vote.find(params[:id]).destroy
    Voteoption.delete_all "vote_id = #{params[:id]}"
    redirect_to :action => 'list'
  end
end
