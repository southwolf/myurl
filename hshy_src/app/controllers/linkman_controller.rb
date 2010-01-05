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
    
    #录入人看自己录入的联系人
    @linkmen = Linkman.find(:all, :conditions=>"user_id = #{session[:user].id}", :order=>"id desc")
    
    #门店经理可看本店所有联系人
    user_ids = session[:user].employer.collect{|u| u.id}
    user_ids << -1
    @linkmen += Linkman.find(:all, :conditions=>"user_id in (#{user_ids.join(',')})")
    
    
    user_ids = session[:user].department.users.collect{|u| u.id}
    user_ids << -1
    #录入客源10天后未成交；本店资深置业顾问也可查看
    if session[:user].is?('资深置业顾问')
      @linkmen += Linkman.find(:all, :conditions=>"inputtime < '#{Time.new.ago(60*60*24*10).strftime('%Y-%m-%d')}' and deal <> 1 and user_id in (#{user_ids.join(',')})")
    end
    
    #录入15天后，高级置业顾问也可看
    if session[:user].is?('高级置业顾问')
      @linkmen += Linkman.find(:all, :conditions=>"inputtime < '#{Time.new.ago(60*60*24*15).strftime('%Y-%m-%d')}' and deal <> 1 and user_id in (#{user_ids.join(',')})")
    end
    
    #18天后置业顾问也可看
    if session[:user].is?('高级置业顾问')
      @linkmen += Linkman.find(:all, :conditions=>"inputtime < '#{Time.new.ago(60*60*24*18).strftime('%Y-%m-%d')}' and deal <> 1 and user_id in (#{user_ids.join(',')})")
    end
    
    #20天后本店人都可看
    @linkmen += Linkman.find(:all, :conditions=>"inputtime < '#{Time.new.ago(60*60*24*20).strftime('%Y-%m-%d')}' and deal <> 1 and user_id in (#{user_ids.join(',')})")
  
    #25天后本区域人都可看
    user_ids = session[:user].same_quyu_user().collect{|u| u.id}
    user_ids << -1
    @linkmen += Linkman.find(:all, :conditions=>"inputtime < '#{Time.new.ago(60*60*24*25).strftime('%Y-%m-%d')}' and deal <> 1 and user_id in (#{user_ids.join(',')})")
  
    
    #30天后全公司人都可看
    @linkmen += Linkman.find(:all, :conditions=>"inputtime < '#{Time.new.ago(60*60*24*30).strftime('%Y-%m-%d')}' and deal <> 1")
  
    @linkmen.uniq!
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
  
  def set_deal
    @linkman = Linkman.find(params[:id])
  end
  
  def update_deal
    if params[:linkman][:deal_type] == "1"  #售房报告 
      cj = Sfcj.find(params[:linkman][:cj_id]) rescue nil
    else  params[:linkman][:deal_type] == "2" #租赁报告
      cj = Zlcj.find(params[:linkman][:cj_id]) rescue nil
    end
    if !cj
      flash[:notice] = '设置成交报告失败，请检查ID是否正确.'
      redirect_to :action=>"list"
      return
    end
    
    @linkman = Linkman.find(params[:id])
    @linkman.dealtime = Time.new
    @linkman.deal = 1
    if @linkman.update_attributes(params[:linkman])
      flash[:notice] = '设置成交报告成功.'
    end
    redirect_to :action=>"list"
  end
end
