class YtaplRightController < ApplicationController
  layout "right"
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @ytapl_right_pages, @ytapl_rights = paginate :ytapl_rights, :per_page => 20
  end

  def show
    @ytapl_right = YtaplRight.find(params[:id])
  end

  def new
    @ytapl_right = YtaplRight.new
    render :layout=>'popup'
  end

  def create
    @ytapl_right = YtaplRight.new(params[:ytapl_right])
    if @ytapl_right.name.size == 0
      flash[:notice] = '添加权限失败，请输入权限名称'
      render :action=>'new', :layout=>'popup'
      return
    end
    if @ytapl_right.save
      flash[:notice] = '添加权限成功'
    end
    
    render :action => "finish", :layout=>'popup'
  end

  def edit
    @ytapl_right = YtaplRight.find(params[:id])
    render :layout=>'popup'
  end

  def update
    @ytapl_right = YtaplRight.find(params[:id])
    
    if @ytapl_right.update_attributes(params[:ytapl_right])
      flash[:notice] = '修改权限成功'
    end
    render :action => "finish", :layout=>'popup'
  end

  def destroy
    YtaplRight.find(params[:id]).destroy
    redirect_to :action => 'list'
    flash[:notice] = '删除权限成功'
  end
  
  def down_excel
     row_count=0
     @all_right=YtaplRight.find(:all)
     workbook = Excel.new("tmp/right.xls")
     worksheet = workbook.add_worksheet(EncodeUtil.change("GB2312", "UTF-8", "权限信息"))
     format0=workbook.add_format(:color => "black",:bold => 0,:bg_color => "gray")
     format1=workbook.add_format(:color => "black",:bold => 0,:bg_color => "silver")
     format2=workbook.add_format(:color => "black",:bold => 0)
     format3=workbook.add_format(:bold => 0)
     worksheet.format_column(0,10,format3)
     worksheet.format_column(1,20,format3)
     worksheet.format_column(2,70,format3)
     Integer(0).upto(2)do|i|
       worksheet.write(0,i,"",format0)
     end
     worksheet.write(0,0,EncodeUtil.change("GB2312", "UTF-8", "ID号"),format0)
     worksheet.write(0,1,EncodeUtil.change("GB2312", "UTF-8", "权限名称"),format0)
     worksheet.write(0,2,EncodeUtil.change("GB2312", "UTF-8", "描述"),format0)
     for right in @all_right
        row_count=row_count+1
        if row_count%2==1
          format = format2
        else
          format = format1
        end
        worksheet.write(row_count,0,right['id'], format)
        worksheet.write(row_count,1,EncodeUtil.change("GB2312","UTF-8",right.name),format)
        worksheet.write(row_count,2,EncodeUtil.change("GB2312","UTF-8",right.desc),format)
     end
     workbook.close
     send_file "tmp/right.xls"
  end
end
