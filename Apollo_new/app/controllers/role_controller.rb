class RoleController < ApplicationController
  layout "right"
  before_filter :check_right
  
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
    @role_pages, @roles = paginate :YtaplRole, :per_page => 20
  end
  
  def new
    @role = YtaplRole.new
#   @privilege = SetOfPrivileges.new
    render :layout=>'popup'
  end
  
  def create
    @role = YtaplRole.new(params[:role])
    @role.datecreated=Time.new
    
    #加权限
#    pri = SetOfPrivileges.new
#    rights = params[:rightIDs].split(',')
#    for right in rights
#      pri[right.to_i] = true
#    end
#    @role.userrights = pri.text
    
    if @role.save
       flash[:notice] = '角色添加成功'
    else
       flash[:notice] = '角色添加失败'
    end
    
    render :action => "finish", :layout=>'popup'
   end
   
   def edit
    @role = YtaplRole.find(params[:id])
#    @privilege = SetOfPrivileges.new
#    @privilege.text = @role.userrights
    render :layout=>'popup'
   end
   
   def update
    @role = YtaplRole.find(params[:id])
    @role.datemodified=Time.new
    #加权限
#    pri = SetOfPrivileges.new
#    rights = params[:rightIDs].split(',')
#    for right in rights
#      pri[right.to_i] = true
#    end
#    @role.userrights = pri.text
    
    if @role.update_attributes(params[:role])
      flash[:notice] = '角色更新成功'
    else
      flash[:notice] = '角色更新失败'
    end
    render :action => "finish", :layout=>'popup'
   end
   
  def destroy
    YtaplRole.find(@params['id']).destroy
    flash[:notice] = '角色删除成功'
    redirect_to :action => 'list'
  end
  
  def down_excel
     send_file export_to_excel
  end
private
  def export_to_excel
     row_count=0
     @all_role=YtaplRole.find(:all)
     workbook = Excel.new("tmp/role.xls")
     worksheet = workbook.add_worksheet(EncodeUtil.change("GB2312", "UTF-8", "组管理"))
     format0=workbook.add_format(:color => "black",:bold => 0,:bg_color => "gray")
     format1=workbook.add_format(:color => "black",:bold => 0,:bg_color => "silver")
     format2=workbook.add_format(:color => "black",:bold => 0)
     format3=workbook.add_format(:bold => 0)
     worksheet.format_column(0,20,format3)
     worksheet.format_column(1,40,format3)
     worksheet.format_column(2,20,format3)
     worksheet.format_column(3,20,format3)
     worksheet.format_column(4,20,format3)
     Integer(0).upto(4)do|i|
       worksheet.write(0,i,"",format0)
     end
     worksheet.write(0,0,EncodeUtil.change("GB2312", "UTF-8", "ID号"),format0)
     worksheet.write(0,1,EncodeUtil.change("GB2312", "UTF-8", "详细日期"),format0)
     worksheet.write(0,2,EncodeUtil.change("GB2312", "UTF-8", "创建日期"),format0)
     worksheet.write(0,3,EncodeUtil.change("GB2312", "UTF-8", "修改日期"),format0)
     worksheet.write(0,4,EncodeUtil.change("GB2312", "UTF-8", "备注"),format0)
     if @all_role!=nil
       for role in @all_role
         row_count=row_count+1
           if row_count%2==1
             worksheet.write(row_count,0,role.roleid,format2)
             worksheet.write(row_count,1,EncodeUtil.change("GB2312","UTF-8",role.name),format2)
             if role.datecreated
               worksheet.write(row_count,2,role.datecreated.strftime("%y-%m-%d"),format2)
             else
               worksheet.write(row_count,2,"",format2)
             end
             if role.datemodified
               worksheet.write(row_count,3,role.datemodified.strftime("%y-%m-%d"),format2)
             else
               worksheet.write(row_count,3,"",format2)
             end
             worksheet.write(row_count,4,EncodeUtil.change("GB2312","UTF-8",role.memo),format2)
           else
             worksheet.write(row_count,0,role.roleid,format1)
             worksheet.write(row_count,1,EncodeUtil.change("GB2312","UTF-8",role.name),format1)
             if role.datecreated
               worksheet.write(row_count,2,role.datecreated.strftime("%y-%m-%d"),format1)
             else
               worksheet.write(row_count,2,"",format1)
             end
             if role.datemodified
               worksheet.write(row_count,3,role.datemodified.strftime("%y-%m-%d"),format1)
             else
               worksheet.write(row_count,3,"",format1)
             end
             worksheet.write(row_count,4,EncodeUtil.change("GB2312","UTF-8",role.memo),format1)
           end

       end
     end
     workbook.close
     "tmp/role.xls"
   end
end
