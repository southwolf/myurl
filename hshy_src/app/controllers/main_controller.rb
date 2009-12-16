require 'ScriptEngine'
require 'XMLHelper'
class MainController < ApplicationController
  def index
    @roots = YtwgFunction.find(:all, :conditions=>"parent_id is null or parent_id=''")
    @user = YtwgUser.find(session[:user].id)
  end
  
  def welcome
    @news = YtwgNews.find(:all, :order=>"id desc", :limit=>5)
    @notice = Notice.find(:all, :order=>"id desc", :limit=>5)
    @tip = Tip.find(:all, :conditions=>"user_id = #{session[:user].id}", :order=>"id desc", :limit=>1)[0]
    @tip = Tip.new if !@tip
    @pictures = Picture.find(:all, :limit=>5, :order=>"id desc")
    render :layout=>'notoolbar_app'
  end
  
  #切换风格
  def style
    user = YtwgUser.find(session[:user].id)
    user.style = params[:style]
    user.save
    session[:user] = user
    redirect_to :action=>'index'
  end
  
  #设置OA名称
  def set_title
    config = YtwgSystem.find(:all, :limit=>1)[0]
    config.title = EncodeUtil.change("GB2312", "UTF-8", params[:value])
    config.save
    render :text=>EncodeUtil.change("GB2312", "UTF-8", params[:value])
  end
  
  def tick
    user = YtwgUser.find(params[:id])
    user.last_tick = Time.new
    user.save
    
    #有未读过的消息
    @messages = Message.find(:all, :conditions=>"to_id = #{session[:user].id} and isread is null")
    render :layout=>false
  end
  
  def no_right
    render :layout=>"application"
  end
  
  def single_pretty_edit
    single_pretty(true)
  end
  
  def single_pretty_show
    single_pretty(false)
  end
  
  def double_pretty_edit
    double_pretty(true)
  end
  
  def double_pretty_show
    double_pretty(false)
  end
  
  #导出为excel文件
  def down_excel
    YtwgAnontable.set_table_name(params[:tablename])
    YtwgAnontable.set_primary_key(params[:keyname])
    YtwgAnontable.reset_column_information
    @record = YtwgAnontable.find(params[:id])
    func = YtwgFunction.find(params[:function_id]) rescue nil
    if func
        helper = $Templates[params[:function_id]]
        set_table_data(helper.tables[0], @record)
        send_file helper.ExportToExcel([helper.tables[0]], helper.dictionFactory), :filename =>(params[:tablename]+"_"+params[:id]) + ".xls"
        return
    end
    render :text=>'没有返回页'
  end
  
  def down_pdf
    YtwgAnontable.set_table_name(params[:tablename])
    YtwgAnontable.set_primary_key(params[:keyname])
    YtwgAnontable.reset_column_information
    @record = YtwgAnontable.find(params[:id])
    func = YtwgFunction.find(params[:function_id]) rescue nil
    if func
        @view = func.template
        helper = XMLHelper.new
        helper.ReadFromString(EncodeUtil.change("GB2312", "UTF-8", @view))
        set_table_data(helper.tables[0], @record)
        send_file helper.ExportToPDF([helper.tables[0]], helper.dictionFactory), :filename =>(params[:tablename]+"_"+params[:id]) + ".pdf"
        return
    end
    render :text=>'没有返回页'
  end
  
  def print_single_table
    single_pretty(false, true)
  end
  
  def print_double_table
    single_pretty(false, true)
  end
  
  def updatecell
    cell_arr = params[:cell].split(".")
    YtwgAnontable.set_table_name(cell_arr[0])
    begin
      record = YtwgAnontable.find(params[:key])
      record[cell_arr[1]] = params[:value]
      record.save
      record.reload
    rescue
      render :text=>'错误'
      return
    end
    result = record.send(cell_arr[1])
    result = result.strftime("%Y-%m-%d") if result.kind_of?(Time)
    if result.kind_of?(TrueClass) || result.kind_of?(FalseClass)
      result = '是' if result.kind_of?(TrueClass)
      result = '否' if result.kind_of?(FalseClass)
    end
    render :text => result.to_s
  end
  
  def update_floatcell
    p params
    cell_arr = params[:cell].split(".")
    YtwgAnontable.set_table_name(params[:float_tablename])
    YtwgAnontable.set_primary_key(params[:float_keyname])
    YtwgAnontable.reset_column_information
    begin
      p "#{params[:float_foreignkeyname]}=#{params[:foreign_key]}"
      p params[:floatindex].to_i
      records = YtwgAnontable.find(:all, :conditions=>"#{params[:float_foreignkeyname]}=#{params[:foreign_key]}", :order=>"#{params[:float_keyname]}", :offset=>params[:floatindex].to_i)
      p records
      if records.size > 0
        p records[0]
        records[0][cell_arr[1].downcase] = params[:value]
        records[0].save
        records[0].reload
      else
        render :text=>'错误'
        return
      end      
    rescue 
      render :text=>'错误'
      return
    end
    
    result = records[0][cell_arr[1].downcase]
    if result.kind_of?(TrueClass) || result.kind_of?(FalseClass)
      result = '是' if result.kind_of?(TrueClass)
      result = '否' if result.kind_of?(FalseClass)
    end
    render :text => result.to_s
  end
  
  def audit
    YtwgAnontable.set_table_name(params[:tablename])
    YtwgAnontable.set_primary_key(params[:keyname])
    YtwgAnontable.reset_column_information
    @record = YtwgAnontable.find(params[:id])
    func = YtwgFunction.find(params[:function_id]) rescue nil
    @errors = Array.new
    @warns = Array.new
    if func
        @view = func.template
        helper = XMLHelper.new
        helper.ReadFromString(EncodeUtil.change("GB2312", "UTF-8", @view))
        scriptengine = TaskScriptEngine.new('', helper.script, '', nil, helper.tables, [@record])
        scriptengine.Prepare
        scriptengine.ExecuteAllAudit()
        for error in scriptengine.GetErrors()
          @errors << error
        end
      
        for warn in scriptengine.GetWarns()
          @warns << warn
        end
    end
    render :layout=>false
  end
  
  def calc
    YtwgAnontable.set_table_name(params[:tablename])
    YtwgAnontable.set_primary_key(params[:keyname])
    YtwgAnontable.reset_column_information
    @record = YtwgAnontable.find(params[:id])
    func = YtwgFunction.find(params[:function_id]) rescue nil
    @errors = Array.new
    @warns = Array.new
    if func
        @view = func.template
        helper = XMLHelper.new
        helper.ReadFromString(EncodeUtil.change("GB2312", "UTF-8", @view))
        scriptengine = TaskScriptEngine.new('', helper.script, '', nil, helper.tables, [@record])
        scriptengine.Prepare
        scriptengine.ExecuteAllCalc()
        @record.save
        flash[:notice] = '运算完毕'
    end
    
    pretty()
  end
  
  def get_child_dict
    p params
  end
  
  def getdict_from_table
    p params
    YtwgAnontable.set_table_name(params[:dict])
    YtwgAnontable.set_primary_key(:id)
    YtwgAnontable.reset_column_information
    dicts = YtwgAnontable.find(:all)
    text = "<script LANGUAGE='JavaScript'>"
    for dict in dicts
      text << "var tree_#{dict.id} = new WebFXTree('#{dict.name}');"
      text << "\ntree_#{dict.id}.action = \"javascript:select_cellvalue(#{dict.id}, '#{dict.name}','dict_#{dict.id}')\";\n"
      text << "document.write(tree_#{dict.id});"
    end
    text << "</script>"
#           result << "\t\t<script LANGUAGE='JavaScript'>\n"
#           for item in diction.GetRootItems
#             result << "\t\tvar tree_#{diction.ID}_#{item} = new WebFXTree('#{EncodeUtil.change('GB2312', 'UTF-8', diction.GetItemName(item))}');\n"
#             result << "\t\ttree_#{diction.ID}_#{item}.action = \"javascript:select_cellvalue(#{item}, '#{EncodeUtil.change('GB2312', 'UTF-8', diction.GetItemName(item))}','dict_#{diction.ID}')\";\n"
#             
#             result << "\t\tdocument.write(tree_#{diction.ID}_#{item});\n"
#           end           
#           result << "\t\t</script>\n"
    p text
    render :text=>text, :layout=>false
  end
  
  def getdict
    result = "<select id='select-' onblur = 'javascript:cellBlur()' style='background-color:#FFFF99;BORDER-BOTTOM: solid 0px; BORDER-LEFT: dashed 0px; BORDER-RIGHT: dashed 0px; BORDER-TOP: dashed 0px;height=100%; width=100%;margin:-1pt 0pt 0pt 0pt '>"
    
    func = YtwgFunction.find(params[:function_id]) rescue nil
    if func
        @view = func.template
        helper = XMLHelper.new
        helper.ReadFromString(EncodeUtil.change("GB2312", "UTF-8", @view))
        dict = helper.dictionFactory.GetDictionByID(params[:dictid])
        if dict
          dict.GetAllItems.each{|key, value|
            result += "<option value='#{key}'>#{value}</option>"
          }
        end
    end
    
    result += "</select>"
    render :text=>result          
  end
  
  def add_float_row
    p params
    YtwgAnontable.set_table_name(params[:float_tablename])
    YtwgAnontable.set_primary_key(params[:float_keyname])
    YtwgAnontable.reset_column_information
    record = YtwgAnontable.new
    record[params[:float_foreignkeyname]] = params[:foreign_key]
    record.save
    
    double_pretty(true, false, true)
    #render :text=>'haha'
  end
  
  def daka
    render :action=>"daka", :layout=>"application"
  end
  
  def do_daka
    p params
    user = YtwgUser.find(params[:user])
    
    digest = Digest::MD5.new
    digest << params[:password]
    dbpassword = digest.hexdigest
    
    if user.password == dbpassword
      #检查是否有重复打卡
      now = Time.new
      count = Daka.count "user_id = #{params[:user]} and ticktime>'#{now.beginning_of_day.to_formatted_s(:db)}' and ticktime<'#{now.tomorrow.beginning_of_day.to_formatted_s(:db)}'"
      if count > 0
        flash[:notice] = "#{user.truename}今天已经打卡了"
        render :action=>"daka", :layout=>"application"
        return
      end
      daka = Daka.new
      daka.user_id = params[:user]
      daka.ticktime = Time.new
      daka.save
      flash[:notice] = "#{user.truename}打卡成功"
      render :action=>"daka", :layout=>"application"
    else
      flash[:notice] = "密码错误，打卡失败"
      render :action=>"daka", :layout=>"application"
    end
  end
private
  def single_pretty(edit_able=true, print=false)
    params[:keyname]='id' if !params[:keyname]
    
    YtwgAnontable.set_table_name(params[:tablename])
    YtwgAnontable.set_primary_key(params[:keyname])
    YtwgAnontable.reset_column_information
    @record = YtwgAnontable.find(params[:id])
    func = YtwgFunction.find(params[:function_id]) rescue nil
    @edit_able = edit_able
    @print = print
    if func
        helper = $Templates[params[:function_id]]
        @style = helper.StyleToHTML(helper.tables[0])
        @html = helper.TableToEditHTML(helper.tables[0], helper.dictionFactory, {:encoding=>"utf-8", :only_table_tag=>true, :record=>@record})
        render :action=>"prettytable", :layout=>'application'
        return
    end
    render :text=>'没有返回页'
  end
  
  def double_pretty(edit_able=true, print=false, nolayout=false)
    #主表
    YtwgAnontable.set_table_name(params[:tablename])
    YtwgAnontable.set_primary_key(params[:keyname]||'id')
    YtwgAnontable.reset_column_information
    @record = YtwgAnontable.find(params[:id])
    
    #浮动表
    YtwgAnontable.set_table_name(params[:float_tablename])
    YtwgAnontable.set_primary_key(params[:float_keyname])
    YtwgAnontable.reset_column_information
    floats = YtwgAnontable.find(:all, :conditions=>"#{params[:float_foreignkeyname]}=#{params[:id]}", :order=>"#{params[:float_keyname]}")
    
    func = YtwgFunction.find(params[:function_id]) rescue nil
    @edit_able = edit_able
    @print = print
    
    float_hash = Hash.new
    if func
        @view = func.template
        helper = XMLHelper.new
        helper.ReadFromString(EncodeUtil.change("GB2312", "UTF-8", @view))
        
        #获得浮动行
        Integer(0).upto(helper.tables[0].GetRowCount) do |row|
          if helper.tables[0].IsFloatTemplRow(row)
            float_hash[helper.tables[0].PhyRowToLogicRow(row+1)] = floats
          end
        end
        
        p float_hash
        
        @style = helper.StyleToHTML(helper.tables[0])
        @html = helper.TableToEditHTML(helper.tables[0], helper.dictionFactory, {:encoding=>"utf-8", :only_table_tag=>true, :record=>@record, :float_record => float_hash})
        @double_mode = true
        
        if nolayout
          render :text=>@html
        else
          render :action=>"prettytable", :layout=>'application'
        end
        return
    end
    render :text=>'没有返回页'
  end 
  
end
