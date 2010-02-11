class UserController < ApplicationController
  layout "right"
  before_filter :check_right, :except=>[:editprofile, :updateprofile]
  
  def check_right
    if !CheckRight(session[:user].id, '管理用户')
      flash[:error] = "对不起，权限不足！"
      redirect_to :controller=>'application', :action=>'noprevilege_request' 
    end
  end  
  
  def index
    list
    render :action => 'list'
  end
  
  def list
    @user_pages, @users = paginate :YtaplUser, :per_page => 20
  end
  
  def show_notpass
    @user_pages, @users = paginate :YtaplUser, :per_page => 20, :conditions=>"flag<>1 or flag is null"
    render :action=>'list'
  end
  
  def show
    @user = YtaplUser.find(@params['id'])
  end
  
  def new
    @user = YtaplUser.new
    render :layout=>'popup'
  end
  
  def create
    same_users = YtaplUser.find(:all, :conditions=>"name='#{params[:user][:name]}'")
    if same_users.size>0
      flash[:notice] = "添加用户失败，存在同名用户！"
      render :action=>'finish', :layout=>'popup'
      return
    end
    @user = YtaplUser.new(params[:user])
    @user.roleid = YtaplRole.find(:all)[params[:roleid].to_i].id
    @user.datecreated = Time.new
    #@user.password = params[:password]
    
    digest = Digest::MD5.new
    digest << params[:password]
    @user.password = digest.hexdigest
      
    if @user.save
       groups = params[:groupIDs].split(',') 
          for group in groups 
          member = Ytgroupmember.new
          member.groupid = group
          member.userid = @user.id
          member.save
       end
       
       flash[:notice] = '添加用户成功'
       #redirect_to :action => 'list'
    else
       flash[:notice] = '添加用户失败'
       #render :action => 'list'
    end
    
    render :action=>'finish', :layout=>'popup'
   end
   
   def edit
    @user = YtaplUser.find(params[:id])
    render :layout=>'popup'
   end
   
   def editprofile
    @user = YtaplUser.find(params[:id])
    render :layout=>"popup"
   end
   
   def updateprofile
    @user = YtaplUser.find(params[:id])    
    digest = Digest::MD5.new
    digest << params[:password]
    @user.password = digest.hexdigest
    if @user.update_attributes(@params['user'])
      #flash[:notice] = '更改用户信息成功'
#      
#      begin
#       #更改荣润的用户表
#       RongrunUser.establish_connection(
#	   :adapter=>"sqlserver",
#	   :host=>$RONGRUN_HOST,
#	   :database=>"zhongyang",
#	   :username=>"sa",
#	   :password=>"",
#	   :encoding=>"utf-8")
#	   
#	   @users = RongrunUser.find(:all, :conditions=>"name='#{@user.name}'")
#	   if @users.size > 0
#	     @users[0].password = @user.password
#	     @users[0].save
#	   end
#      rescue
#      end
#      redirect_to :controller=>"main", :action=>"index"
    else
      #flash[:notice] = '更改用户信息失败'
      redirect_to :controller=>"main", :action=>"index"
    end
   end
   
   def update
    @user = YtaplUser.find(params[:id])
    @user.roleid = YtaplRole.find(:all)[params[:roleid].to_i].id
    #@user.password = params[:password]
    if params[:modifyPassword] == "true"
      digest = Digest::MD5.new
      digest << params[:password]
      @user.password = digest.hexdigest
    end    
    
    Ytgroupmember.delete_all("userid = #{@user.id}")
    groups = params[:groupIDs].split(',') 
    for group in groups 
      member = Ytgroupmember.new
      member.groupid = group
      member.userid = @user.id
      member.save
    end
    @user.datemodified = Time.new

    if @user.update_attributes(@params['user'])
      flash[:notice] = '更改用户信息成功'
#     begin  
#      #更改荣润的用户表
#      RongrunUser.establish_connection(
#	   :adapter=>"sqlserver",
#	   :host=>$RONGRUN_HOST,
#	   :database=>"zhongyang",
#	   :username=>"sa",
#	   :password=>"",
#	   :encoding=>"utf-8")
#	   
#	   @users = RongrunUser.find(:all, :conditions=>"id='#{@user.name}'")
#	   if @users.size > 0
#	     YtLog.info "rongrun user found"
#	     YtLog.info @users[0]
#	     @users[0].password = @user.password
#	     @users[0].save
#	   end
#	  rescue
#	  end 
	   
    else
      flash[:notice] = '更改用户信息失败'
    end
    
    render :action=>'finish', :layout=>'popup'
   end
   
  def search
    @users = YtaplUser.find_all_by_name(@params[:name])
    render :action => 'list'
  end
  
  def audit_pass
    ids = params[:id].split(',')
    for id in ids
      user = YtaplUser.find(id)
      user.flag = 1
      user.save
    end
    flash[:notice] = '审核用户成功'
    redirect_to :action => 'list'
  end
  
  def audit_stop
    id = params[:id]
    user = YtaplUser.find(id)
    user.flag = 0
    user.save
    flash[:notice] = '停用用户帐号成功'
    redirect_to :action => 'list'
  end
   
  def destroy
    YtaplUser.find(@params['id']).destroy
    flash[:notice] = '删除用户成功'
    redirect_to :action => 'list'
  end
  
  def query
    @user_pages, @users = paginate :YtaplUser, :per_page => 10, :conditions=>"name like '%#{params[:userName]}%' and (enterprisename like '%#{params[:enterpriseInfo]}%' or enterprisename is null)"
    @q_username = params[:userName]
    @q_enterprise = params[:enterpriseInfo]
    flash[:notice] = '查询完毕'
    render :action=>'list'
  end
  
  def down_excel
     send_file export_to_excel
  end
private
  def export_to_excel
     row_count=0
     @all_user=YtaplUser.find(:all)
     workbook = Excel.new("tmp/user.xls")
     worksheet = workbook.add_worksheet(EncodeUtil.change("GB2312", "UTF-8", "组管理"))
     format0=workbook.add_format(:color => "black",:bold => 0,:bg_color => "gray")
     format1=workbook.add_format(:color => "black",:bold => 0,:bg_color => "silver")
     format2=workbook.add_format(:color => "black",:bold => 0)
     format3=workbook.add_format(:bold => 0)
     worksheet.format_column(0,20,format3)
     worksheet.format_column(1,20,format3)
     worksheet.format_column(2,40,format3)
     worksheet.format_column(3,20,format3)
     worksheet.format_column(4,20,format3)
     Integer(0).upto(4)do|i|
       worksheet.write(0,i,"",format0)
     end
     worksheet.write(0,0,EncodeUtil.change("GB2312", "UTF-8", "用户名"),format0)
     worksheet.write(0,1,EncodeUtil.change("GB2312", "UTF-8", "企业名称"),format0)
     worksheet.write(0,2,EncodeUtil.change("GB2312", "UTF-8", "法人代表"),format0)
     worksheet.write(0,3,EncodeUtil.change("GB2312", "UTF-8", "联系人"),format0)
     worksheet.write(0,4,EncodeUtil.change("GB2312", "UTF-8", "所属角色"),format0)
     if @all_user!=nil
       for user in @all_user
         row_count=row_count+1
           if row_count%2==1
             worksheet.write(row_count,0,user.name,format2)
             if user.enterprisename
               worksheet.write(row_count,1,EncodeUtil.change("GB2312","UTF-8",user.enterprisename),format2)
             else
               worksheet.write(row_count,1,"",format2)
             end
             if user.lawpersionname
               worksheet.write(row_count,2,EncodeUtil.change("GB2312","UTF-8",user.lawpersionname),format2)
             else
               worksheet.write(row_count,2,"",format2)
             end
             if user.contactpersionname
               worksheet.write(row_count,3,EncodeUtil.change("GB2312","UTF-8",user.contactpersionname),format2)
             else
               worksheet.write(row_count,3,"",format2)
             end
             if user.roleid
               role=YtaplRole.find(:first , :conditions => ["roleid=?",user.roleid] )
               worksheet.write(row_count,4,EncodeUtil.change("GB2312","UTF-8",role.name),format2)
             else
               worksheet.write(row_count,4,"",format2)
             end
           else
             worksheet.write(row_count,0,user.name,format1)
             if user.enterprisename
               worksheet.write(row_count,1,EncodeUtil.change("GB2312","UTF-8",user.enterprisename),format1)
             else
               worksheet.write(row_count,1,"",format1)
             end
             if user.lawpersionname
               worksheet.write(row_count,2,EncodeUtil.change("GB2312","UTF-8",user.lawpersionname),format1)
             else
               worksheet.write(row_count,2,"",format1)
             end
             if user.contactpersionname
               worksheet.write(row_count,3,EncodeUtil.change("GB2312","UTF-8",user.contactpersionname),format1)
             else
               worksheet.write(row_count,3,"",format1)
             end
             if user.roleid
               role=YtaplRole.find(:first , :conditions => ["roleid=?",user.roleid] )
               worksheet.write(row_count,4,EncodeUtil.change("GB2312","UTF-8",role.name),format1)
             else
               worksheet.write(row_count,4,"",format1)
             end
           end
       end
     end
     workbook.close
     "tmp/user.xls"
   end
end