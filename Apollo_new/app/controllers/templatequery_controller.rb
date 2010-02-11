require "XMLHelper"
require "ReportEngine"
require "EncodeUtil"
require 'zlib'

class TemplatequeryController < ApplicationController  
  layout "main"
  def index
    @templates = Ytreporttemplate.find(:all, :conditions=>"taskid = '#{session[:task].strid}'", :order=>"reserved1") 
    if @templates.size > 0
      list_result @templates[0].id
    else
      list_result
    end
  end
  
  def custom_tasktimes
    render :layout=>'popup'
  end
  
  def query
    if !params[:templates]
      render :text => 'not valid'    
      return
    end
    
    if params[:taskTimeIDs][params[:taskTimeIDs].size-1, 1] == ","
      params[:taskTimeIDs] = params[:taskTimeIDs][0, params[:taskTimeIDs].size-1]
    end
    tasktimeids = params[:taskTimeIDs].split(',')
    unitids = params[:unitIDs].split(',')
    
    #将没有权限的单位过滤掉
    permitted_unitids = GetPermitUnits(session[:task].id, session[:user].id)
    temp = Array.new
    for unitid in unitids 
      temp << unitid if permitted_unitids.include?(unitid)
    end
    unitids = temp
    
    #构造数据源
    helper = $TaskDesc[session[:task].strid].helper
    
    tables_sql = ""
    for table in helper.tables
      tables_sql += "ytapl_#{session[:task].strid.downcase}_#{table.GetTableID().downcase} #{table.GetTableID().downcase},"
    end
    tables_sql = tables_sql[0, tables_sql.size-1]
    
    conditions = "1=1 "
    1.upto(helper.tables.size-1) do |index|
      conditions += " and #{helper.tables[index].GetTableID().downcase}.unitid = #{helper.tables[0].GetTableID().downcase}.unitid "
    end
    2.upto(helper.tables.size-1) do |index|
      conditions += " and #{helper.tables[index].GetTableID().downcase}.tasktimeid = #{helper.tables[1].GetTableID().downcase}.tasktimeid "
    end
    conditions += " and #{helper.tables[1].GetTableID().downcase}.tasktimeid in (#{params[:taskTimeIDs]}) "
    
    unit_forest = GetUnitForest(session[:task].id, session[:user].id)
    if params[:unitIDs].size > 0
      temp = ""
      for element in unitids
        temp += "'" + element + "'" + ","
      end
      temp = temp[0, temp.size-1]
      conditions += " and #{helper.tables[0].GetTableID().downcase}.unitid in (#{temp})"
    else
      temp = ""
      for element in permitted_unitids
        temp += "'" + element + "'" + ","
      end
      temp = temp[0, temp.size-1]
   	  conditions += " and #{helper.tables[0].GetTableID().downcase}.unitid in (#{temp})"
    end
    
    engine = ReportEngine.new()
    newhelper = XMLHelper.new
    
    @result = Hash.new
    @styles = Hash.new
    tables = []
    for template_id in params[:templates]
      report = Ytreporttemplate.find(template_id)
      newhelper.Ruby_ReadFromXMLString(report.content)
      #将.转成_
      yttable = newhelper.tables[0]
      field_sql = extract_field_sql(yttable)
      @sql = "select #{field_sql} from #{tables_sql} where #{conditions}"
      
      table = engine.fill(newhelper.tables[0], @sql, newhelper.script)
      table.ChangeCurrencyUnit(params[:currency].to_f, helper.parameters['currency.base']||1)
     
      
      if params[:toexcel] != "true"
        style = helper.StyleToHTML(table)
        style = style.gsub(".style", "."+table.GetTableID()+"style")
        @styles[report.templatename] = style
        tablehtml = helper.TableToEditHTML(table, newhelper.dictionFactory, {:script=>newhelper.script, :encoding=>"utf-8", :readonly=>true, :only_table_tag=>true})
        tablehtml = tablehtml.gsub("class = 'style", "class = '"+table.GetTableID()+"style")
        tablehtml = tablehtml.gsub("class='style", "class = '"+table.GetTableID()+"style")
        @result[report.templatename] = tablehtml
      else
        tables << table
      end
      
      #保存数据
      if params[:savedata] == 'true'
        helper_save = XMLHelper.new
        context = helper_save.REXML_WriteToXML([table], newhelper.dictionFactory, newhelper.script, newhelper.parameters)
        result = Ytreportresult.new
        result.templateid = template_id
        result.name = report.templatename + Time.new().strftime("%Y-%m-%d")
        result.createtime = Time.new        
        result.context = ZipAndBase64(context)
        result.save
      end
    end
    
    if params[:toexcel] == "true"
      helper = XMLHelper.new
      p tables.size
      send_file helper.ExportToExcel(tables), :filename => "report_result.xls"
      return
    end    
    
    render :layout=>false      
  end
  
########################  
  def list_result(templateid=nil)
    if templateid
      @results_page, @results = paginate "ytreportresult", :conditions=>"templateid = #{templateid}", :order=>"id"
    else
      if Ytreporttemplate.count > 0
        @results_page, @results = paginate "ytreportresult", :conditions=>"templateid = #{Ytreporttemplate.find(:all).first.id}"
      else
        @results_page, @results = paginate "ytreportresult", :conditions=>"templateid = -1"
      end
    end
    @templateid = templateid
  end
  
  def save_result
    tempids = params[:templid].split(',')
    for tempid in tempids
      result = Ytreportresult.new
      result.templateid = tempid
      result.name = params[:name]
      result.createtime = Time.new
      helper = XMLHelper.new
      template = Ytreporttemplate.find(tempid)
      unzipper = Zlib::Inflate.new
      result.context = unzipper.inflate(session[:result][template.templatename])
      result.save
    end
    
    render :text => "保存报表结果成功"
  end
  
  def export_result_to_excel
    tables = Array.new
    session[:result].each{|key, value|
      unzipper = Zlib::Inflate.new
      str = '<?xml version="1.0" encoding="gb2312" standalone="no"?>' + unzipper.inflate(value)
      str = EncodeUtil.change("GB2312", "UTF-8", str)
      helper = XMLHelper.new
      helper.ReadFromString(str)
      tables << helper.tables[0]
    }
    
    helper = XMLHelper.new
    send_file helper.ExportToExcel(tables), :filename => "report_result.xls"
    
    
    #send_file helper.ExportToExcel(helper.tables), :filename => "report_result.xls"
  end
  
  def delete_result
    Ytreportresult.find(params[:id]).destroy
    list_result params[:templateid]
    render :partial =>'result', :locals => { :template =>Ytreporttemplate.find(params[:templateid])}
  end
  
  def show_history
    view = DecodeZipAndBase64(Ytreportresult.find(params[:id]).context)
    view = '<?xml version="1.0" encoding="gb2312" standalone="no"?>' + view
    view = EncodeUtil.change("GB2312", "UTF-8", view)
    helper = XMLHelper.new
    helper.ReadFromString(view)
    
    @style = helper.StyleToHTML(helper.tables[0])
    @tablehtml=helper.TableToEditHTML(helper.tables[0], helper.dictionFactory, {:script=>helper.script, :encoding=>"utf-8", :readonly=>true, :only_table_tag=>false})
    list_result
    @resultid = params[:id]
    render :layout=>false
  end
  
  def history_to_excel
    view = DecodeZipAndBase64(Ytreportresult.find(params[:id]).context)
    view = '<?xml version="1.0" encoding="gb2312" standalone="no"?>' + view
    view = EncodeUtil.change("GB2312", "UTF-8", view)
    helper = XMLHelper.new
    helper.ReadFromString(view)
    p helper.tables.size
    send_file helper.ExportToExcel, :filename => "report_result.xls"
  end
  
  def switchcatalog
    list_result params[:catalog]
    render :partial =>'result', :locals=>{:template => Ytreporttemplate.find(params[:catalog])}
  end
  
private
  def extract_field_sql(yttable)
    	fields = []
    	Integer(0).upto(yttable.GetRowCount()-1) do |row|
        next if yttable.IsEmptyRow(row)
        Integer(0).upto(yttable.GetColumnCount()-1) do |col|
          next if yttable.IsEmptyCol(col)
          cell = yttable.GetCell(row, col)
          next if !cell.IsStore()
          newtext = cell.GetText().gsub(/(\w*)\[(\w*)\]/) {|s|
          	fields << s.gsub(/(\w*)\[(\w*)\]/, '\1.\2 as \1_\2')
          }
          newtext = cell.GetText().gsub(/(\w*)\[(\w*)\]/, '\1_\2')
          cell.SetText(newtext.downcase)
        end
      end
      fields.uniq!      
      
      fields.join(',').downcase
      
    end
end
