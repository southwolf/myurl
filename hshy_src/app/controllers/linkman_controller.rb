class LinkmanController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    if session[:user].department.leader_id == session[:user].id
      ids = session[:user].employer.collect{|e| e.id}.join(',')
      @linkmen = Linkman.paginate :page=>params[:page], :per_page => 20, :conditions=>"user_id in (#{ids})", :order=>" id desc "
    else
      @linkmen = Linkman.paginate :page=>params[:page], :per_page => 20, :conditions=>"user_id = #{session[:user].id}", :order=>" id desc "
    end
  end

  def show
    @linkman = Linkman.find(params[:id])
  end

  def new
    @linkman = Linkman.new
  end

  def create
    @linkman = Linkman.new(params[:linkman])
    @linkman.user_id = session[:user].id
    @linkman.inputtime = Time.new
    if @linkman.save
      flash[:notice] = '添加联系人成功.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @linkman = Linkman.find(params[:id])
  end

  def update
    @linkman = Linkman.find(params[:id])
    @linkman.inputtime = Time.new
    if @linkman.update_attributes(params[:linkman])
      flash[:notice] = '修改联系人成功.'
      redirect_to :action => 'show', :id => @linkman
    else
      render :action => 'edit'
    end
  end

  def destroy
    Linkman.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
