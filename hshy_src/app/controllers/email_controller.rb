class EmailController < ApplicationController
  def index
    list
    redirect_to :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    render :layout=>"notoolbar_app"
  end
  
  
  def list_inbox
    mail_ids = UserEmail.find(:all, :conditions=>"user_id = #{session[:user].id} and d is null")
    mail_ids += UserEmailCc.find(:all, :conditions=>"user_id = #{session[:user].id} and d is null")
    @read_tag = {}
    for info in mail_ids
      @read_tag[info.email_id] = info.isread
    end
    
    ids = mail_ids.collect! { |item| item.email_id }
    ids << -1 if ids.size == 0
    ids_str = ids.join(",")
   
    @emails = Email.paginate :page => params[:page], :conditions=>"id in (#{ids_str}) and cg is null", :per_page => 20, :order=>"id desc"
  end
  
  def list_cg
    @emails = Email.paginate :page => params[:page], :conditions=>"from_id = #{session[:user].id} and cg=1", :per_page => 10, :order=>"id desc"
  end
  
  def list_sent
    mail_ids = UserEmail.find(:all, :conditions=>"user_id = #{session[:user].id}")
    mail_ids += UserEmailCc.find(:all, :conditions=>"user_id = #{session[:user].id}")
    @read_tag = {}
    for info in mail_ids
      @read_tag[info.email_id] = info.isread
    end
   
    @emails2 =Email.paginate :page=>params[:page], :conditions=>"from_id = #{session[:user].id}", :order=>"id desc", :per_page=>10
  end
  
  def list_recent
    mail_ids = UserEmail.find(:all, :conditions=>"user_id = #{session[:user].id}")
    mail_ids += UserEmailCc.find(:all, :conditions=>"user_id = #{session[:user].id}")
    @read_tag = [-1]
    for mail_id in mail_ids
      @read_tag << mail_id.email_id if mail_id.isread == 1
    end

    ids = mail_ids.collect{|m| m.email_id}
    ids << -1 if ids.size == 0
    @emails = Email.find(:all,  :conditions=>"id in (#{ids.join(",")}) and cg is null", :order=>"id desc")
  end
  
  def list_recent2
    mail_ids = UserEmail.find(:all, :conditions=>"user_id = #{session[:user].id}")
    mail_ids += UserEmailCc.find(:all, :conditions=>"user_id = #{session[:user].id}")
    @read_tag = [-1]
    for mail_id in mail_ids
      @read_tag << mail_id.email_id if mail_id.isread == 1
    end

    ids = mail_ids.collect{|m| m.email_id}
    ids << -1 if ids.size == 0
    @emails = Email.find(:all,  :conditions=>"id in (#{ids.join(",")}) and cg is null", :order=>"id desc")
    render :layout=>false
  end
  
  def list_delete
    mail_ids = UserEmail.find(:all, :conditions=>"user_id = #{session[:user].id} and d=1")
    mail_ids += UserEmailCc.find(:all, :conditions=>"user_id = #{session[:user].id} and d=1")
    
    @read_tag = [-1]
    for mail_id in mail_ids
      @read_tag << mail_id.email_id if mail_id.isread == 1
    end
    ids = mail_ids.collect{|m| m.email_id}
    ids << -1 if ids.size == 0
    @emails = Email.paginate(:page=>params[:page], :conditions=>"id in (#{ids.join(",")})", :order=>"id desc")
  end

  def show
    @email = Email.find(params[:id])
    
    @email.readusers << session[:user] rescue nil
  end

  def new
    @email = Email.new
    @address = []
    @ccaddress = []
  end
  
  #回复
  def reply
    orig = Email.find(params[:id])
    @email = Email.new
    @email.title = "Re:" + orig.title
    @email.content = "<br><br><h3>在您的邮件中提到:</h3>" + orig.content
    @address = [orig.from_id]
    @ccaddress = []
    render :action=>"new"
  end
  
  #回复所有
  def replyall
    orig = Email.find(params[:id])
    @email = Email.new
    @email.title = "Re:" + orig.title
    @email.content = "<br><br><h3>在您的邮件中提到:</h3>" + orig.content
    @address = orig.users.collect{|e| e.id}
    @address << orig.from_id if !@address.include?(orig.from_id)
    @ccaddress = orig.ccusers.collect{|e| e.id}
    render :action=>"new"
  end
  
  def relay
    orig = Email.find(params[:id])
    @email = Email.new
    @email.title = "Fw:" + orig.title
    @email.content = "<br><br><h3>转发邮件信息:</h3>" + orig.content
    @address = []
    @ccaddress = []
    render :action=>"new"
  end

  def create
    @email = Email.new(params[:email])
    @email.from_id = session[:user].id
    @email.sendtime = Time.new
    @email.title = "无标题" if @email.title.to_s.size == 0
    
    if @email.user_ids.size == 0
      #redirect_to :action=>"new"
      @address = []
      @ccaddress = []
      flash[:error] = "请选择收件人"
      render :action=>"new"      
      return
    end
    
    #设定email的recv字段
    users = YtwgUser.find(:all, :conditions=>"id in (#{@email.user_ids.join(",")})")
    names = users.collect { |item| item.truename }
    @email.recv = names.join(",")
    
    cc_ids = @email.ccuser_ids
    cc_ids << -1
    ccusers = YtwgUser.find(:all, :conditions=>"id in (#{cc_ids.join(",")})")
    names = ccusers.collect { |item| item.truename }
    @email.cc = names.join(",")
    
    users += ccusers
    users.uniq! 
    
    if @email.save
#      for user in users
#        next if user.ip.to_s.size < 2
#        text = EncodeUtil.change('GB2312', 'UTF-8', "您有一封新邮件 发送人:#{YtwgUser.find(@email.from_id).truename} 标题:#{@email.title}")
#        Thread.new() do 
#          system "net send #{user.ip} #{text}"
#        end
#        puts "net send #{user.ip} #{text}"
#      end
      flash[:notice] = '邮件已发送'
    else
      render :action => 'new'
    end
  end

  def edit
    @email = Email.find(params[:id])
  end

  def update
    @email = Email.find(params[:id])
    if @email.update_attributes(params[:email])
      flash[:notice] = 'Email was successfully updated.'
      redirect_to :action => 'show', :id => @email
    else
      render :action => 'edit'
    end
  end

  def destroy
    #Email.find(params[:id]).destroy
    #UserEmail.delete_all "user_id = #{session[:user].id} and email_id = #{params[:id]}"
    #UserEmailCc.delete_all "user_id = #{session[:user].id} and email_id = #{params[:id]}"
    
    UserEmail.update_all "d=1", "user_id = #{session[:user].id} and email_id = #{params[:id]}"
    UserEmailCc.update_all "d=1", "user_id = #{session[:user].id} and email_id = #{params[:id]}"
    redirect_to :action=>"list_inbox"
  end
  
  def destroy2
    #Email.find(params[:id]).destroy
    #UserEmail.delete_all "user_id = #{session[:user].id} and email_id = #{params[:id]}"
    #UserEmailCc.delete_all "user_id = #{session[:user].id} and email_id = #{params[:id]}"
    
    Email.find(params[:id]).destroy
    redirect_to :action=>"list_cg"
  end
  
  def download_attach
    email = Email.find(params[:id])
    send_file email.attach
  end
  
  def download_attach2
    email = Email.find(params[:id])
    send_file email.attach2
  end
  
  def download_attach3
    email = Email.find(params[:id])
    send_file email.attach3
  end
  
  def read_detail
    @email = Email.find(params[:id])
    render :layout=>"notoolbar_app"
  end
  
  def find
    conditions = []
    conditions << "1=1"
    conditions << "title like '%#{params[:title]}%'" if params[:title].size > 0
    conditions << "content like '%#{params[:text]}%'" if params[:text].size > 0
    conditions << "(attach like '%#{params[:attach]}%' or attach2 like '%#{params[:attach2]}%'  or attach3 like '%#{params[:attach3]}')" if params[:attach].size > 0
    conditions << "from_id in (#{params[:sender].join(',')})" if params[:sender]
    
    if params[:box] == '1'  #收件箱
      mail_ids = UserEmail.find(:all, :conditions=>"user_id = #{session[:user].id}")
      mail_ids += UserEmailCc.find(:all, :conditions=>"user_id = #{session[:user].id}")
      ids = mail_ids.collect{|m| m.email_id}
      ids << -1 if ids.size == 0
      @read_tag = [-1]
      for mail_id in mail_ids
        @read_tag << mail_id.email_id
      end
      @emails = Email.paginate(:page=>params[:page], :conditions=>"id in (#{ids.join(",")}) and cg is null and #{conditions.join(' and ')}", :order=>"id desc")
    elsif params[:box] == '2'  #已发送
      @read_tag = [-1]
      @emails = Email.paginate(:page=>params[:page], :conditions=>"from_id = #{session[:user].id} and #{conditions.join(' and ')}", :order=>"id desc")
    elsif params[:box] == '3'  #草稿箱
      @read_tag = [-1]
      @emails = Email.paginate(:page=>params[:page], :conditions=>"from_id = #{session[:user].id}  and cg=1 and #{conditions.join(' and ')}", :order=>"id desc")
    elsif params[:box] == '4'  #已删除
      mail_ids = UserEmail.find(:all, :conditions=>"user_id = #{session[:user].id} and d=1")
      mail_ids += UserEmailCc.find(:all, :conditions=>"user_id = #{session[:user].id} and d=1")

      @read_tag = [-1]
      for mail_id in mail_ids
        @read_tag << mail_id.email_id if mail_id.isread == 1
      end
      ids = mail_ids.collect{|m| m.email_id}
      ids << -1 if ids.size == 0
      @emails = Email.paginate(:page=>params[:page], :conditions=>"id in (#{ids.join(",")}) and #{conditions.join(' and ')}", :order=>"id desc")
     end
  end
end
