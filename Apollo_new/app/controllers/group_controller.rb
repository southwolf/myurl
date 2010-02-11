class GroupController < ApplicationController
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
    @group_pages, @groups = paginate :YtaplGroup, :per_page => 20
  end
  
  def list_all
    @group_pages, @groups = paginate :YtaplGroup, :per_page =>YtaplGroup.count()
    flash[:notice] = '显示所有组完毕'
    render :action=>'list'
  end
  
  #查找组
  def query
    @group_pages, @groups = paginate :YtaplGroup, :conditions=>"name like '%#{params[:groupName]}%'", :per_page =>YtaplGroup.count()
    flash[:notice] = '查找完毕'
    render :action=>'list'
  end
  
  def show
    @group = YtaplGroup.find(@params['id'])
    
  end
  
  def new
    @group = YtaplGroup.new
    render :layout=>'popup'
  end
  
  def create
    @group = YtaplGroup.new(params[:group])
    @group.datecreated=Time.new
    if @group.save
       flash[:notice] = '创建组成功'
       users = params[:userIDs].split(',')    
       for userid in users
          member = Ytgroupmember.new
          member.groupid = @group.id
          member.userid = userid
          member.save
       end
       
       #redirect_to :action => 'list'
    else
       flash[:notice] = '创建组失败'
       #render :action => 'list'
    end
    
    render :action => "finish", :layout=>'popup'
   end
   
   def edit
    @group = YtaplGroup.find(params[:id])
    render :layout=>'popup'
   end
   
   def update
    @group = YtaplGroup.find(params[:id])
    @group.datemodified = Time.new
    if @group.update_attributes(@params[:group])
       Ytgroupmember.delete_all("groupid = #{@group.id}")
       users = params[:userIDs].split(',')    
       for userid in users
          member = Ytgroupmember.new
          member.groupid = @group.id
          member.userid = userid
          member.save
       end
       
      flash[:notice] = '修改组信息成功'
      #redirect_to :action => 'list'
    else
      flash[:notice] = '修改组信息失败'
      #render :action => 'list'
    end
    
    render :action => "finish", :layout=>'popup'
   end
   
  def destroy
    YtaplGroup.find(@params['id']).destroy
    flash[:notice] = '删除组成功'
    redirect_to :action => 'list'
  end
  
  def down_excel
     send_file export_to_excel
  end
  
private
  def export_to_excel
     row_count=0
     @all_group=YtaplGroup.find(:all)
     workbook = Excel.new("tmp/group.xls")
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
     worksheet.write(0,1,EncodeUtil.change("GB2312", "UTF-8", "组名称"),format0)
     worksheet.write(0,2,EncodeUtil.change("GB2312", "UTF-8", "创建日期"),format0)
     worksheet.write(0,3,EncodeUtil.change("GB2312", "UTF-8", "修改日期"),format0)
     worksheet.write(0,4,EncodeUtil.change("GB2312", "UTF-8", "备注"),format0)
     if @all_group!=nil
       for group in @all_group
         row_count=row_count+1
           if row_count%2==1
             worksheet.write(row_count,0,group.groupid,format2)
             worksheet.write(row_count,1,EncodeUtil.change("GB2312","UTF-8",group.name),format2)
             if group.datecreated
               worksheet.write(row_count,2,group.datecreated.strftime("%y-%m-%d"),format2)
             else
               worksheet.write(row_count,2,"",format2)
             end
             if group.datemodified
               worksheet.write(row_count,3,group.datemodified.strftime("%y-%m-%d"),format2)
             else
               worksheet.write(row_count,3,"",format2)
             end
             worksheet.write(row_count,4,EncodeUtil.change("GB2312","UTF-8",group.memo),format2)
           else
             worksheet.write(row_count,0,group.groupid,format1)
             worksheet.write(row_count,1,EncodeUtil.change("GB2312","UTF-8",group.name),format1)
             if group.datecreated
               worksheet.write(row_count,2,group.datecreated.strftime("%y-%m-%d"),format1)
             else
               worksheet.write(row_count,2,"",format1)
             end
             if group.datemodified
               worksheet.write(row_count,3,group.datemodified.strftime("%y-%m-%d"),format1)
             else
               worksheet.write(row_count,3,"",format1)
             end
             worksheet.write(row_count,4,EncodeUtil.change("GB2312","UTF-8",group.memo),format1)
           end

       end
     end
     workbook.close
     "tmp/group.xls"
   end
end
