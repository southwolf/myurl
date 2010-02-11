
require 'Util'
require 'zip/zip'
require 'base64'


include ApplicationHelper
include TransferHelper

class TransferController < ApplicationController  
  
  def index
  end
  
  #上报情况
  def detail
    @tasktimeid =  params[:tasktime].to_i if params[:tasktime]
    @tasktimeid =  session[:tasktime] if !@tasktimeid 
    @optype = params[:type] || "all"    #all:所有情况;notfill:未填报;filled:已填报;query:查询
    @word = params[:codeOrName]         #需要查找的关键字
    
    @optype = 'all' if @word=='' && @optype=='query'
    
    render :action=>'detail', :layout=>"subwindow" 
  end
  
  #上报数据
  def upload
    render :action=>'upload', :layout=>"subwindow" 
  end
  
  #下载数据
  def download
    @convert = YtaplConverttask.find(:all, :conditions=>"taskid=#{session[:task].id}")
    render :action=>'download', :layout=>false  
  end
  
  #跨任务提数
  def convert
    render :action=>'convert', :layout=>false  
  end
  
  def download_convert
    require 'zip/zipfilesystem'
    
    unitid = params[:unitID]
    tasktimeid = params[:taskTimeID].to_i
    recursive = (params[:isRecursive] == "true")
    tasktime = Yttasktime.find(tasktimeid)
    convert = YtaplConverttask.find(params[:convertid])
    meta = $TaskDesc[session[:task].strid]
    
    begin
      doc = Document.new(convert.content)
    rescue
      flash[:error] = "文件格式错误"
      redirect_to :action=>"convert"
      return
    end
    
    
    if recursive
      units = Util.GetChildren(session[:task].strid, unitid)
    else
      
      fmtable = meta.helper.tables[0]
      UnitFMTableData.set_table_name("ytapl_#{session[:task].strid}_#{fmtable.GetTableID()}")
      units = [UnitFMTableData.find(unitid)]
    end
    
    root = doc.root    
    
    file_path = "tmp/#{unitid}.xml"
    file = File.new(file_path, "w")
    file << '<?xml version="1.0" encoding="gb2312" standalone="no"?>'
    file << "<taskModel ID='#{root.attribute("destask")}'>" 
    file << "<taskTime taskTime='#{tasktime.begintime.strftime("%Y-%m-%d") + "T00:00:00+08:00"}'>"
    for unit in units
      records = _GetUnitData(session[:task].strid, unit.unitid, tasktimeid, false)
      next if records.size == 0
      
      
      scriptengine = TaskScriptEngine.new(session[:task].strid, nil, unit.unitid, tasktime.begintime, meta.helper.tables, records)
      scriptengine.Prepare
      
      file << "<unit ID='#{unit.unitid}'>"      
      root.elements.each("table"){|t|
        file << "<table ID='#{t.attributes["name"]}'>"
        t.each_element("field"){|field|
          value = scriptengine.instance_eval(field.text)
          file << "<cell field='#{field.attributes["name"]}' value='#{value}'/>"
        }        
        file << "</table>"
      }
      file << "</unit>"
    end
    file << "</taskTime>"
    file << "</taskModel>"
    file.close
    
    
    Zip::ZipOutputStream.open("tmp/#{unitid}.fap") {
      |zos|
      ze = zos.put_next_entry "db_#{tasktime.begintime.strftime('%Y%m')}.xml"
      #ze = zos.put_next_entry "db.xml"
      file = File.new(file_path, 'rb')
      zos.puts EncodeUtil.change("GB2312", "UTF-8", file.read(File.size(file_path)))
    }
    send_file "tmp/#{unitid}.fap", :stream=>true
  end
  
  
  #用户请求下载某一期的数据
  def download_result
    require 'zip/zipfilesystem'
    
    unitid = params[:unitID]
    tasktimeid = params[:taskTimeID].to_i
    recursive = (params[:isRecursive] == "true")
    tasktime = Yttasktime.find(tasktimeid)
    #取得所有数据，写入文件，压缩，发送给用户
    file_path = Util.ExportUnitData(session[:task].strid, tasktimeid, unitid, recursive)
    Zip::ZipOutputStream.open("tmp/#{unitid}.fap") {
      |zos|
      ze = zos.put_next_entry "db_#{tasktime.begintime.strftime('%Y%m')}.xml"
      #ze = zos.put_next_entry "db.xml"
      file = File.new(file_path, 'rb')
      zos.puts EncodeUtil.change("GB2312", "UTF-8", file.read(File.size(file_path)))
    }
    send_file "tmp/#{unitid}.fap", :stream=>true
  end
   
  #上报到服务器
  def uploadserver
    render :action=>'uploadserver', :layout=>false  
  end
  
  def setup_net
    render :action=>'setup_net', :layout=>false  
  end
  
  def setup_mail
    render :action=>'setup_mail', :layout=>false  
  end
  
  #用户选择并发布一个xml文件
  def upload_data
    aws = FrontServiceController.new
    
    #先写入文件
    file = File.new('tmp\simple.zip', "wb")
    file << params[:file].read()
    file.close
    
    #再解压缩
    begin
    zf=Zip::ZipFile.open('tmp\simple.zip') 
    zf.each_with_index {
      |entry, index|
      if entry.name =~ /\S*\.xml/
  	    #puts "entry #{index} is #{entry.name}, size = #{entry.size}, compressed size = #{entry.compressed_size}"
  	    data = zf.get_input_stream(entry).read()
  	    aws.uploadData2 data, "lmx", "lmx"
      end
    }
    zf.close
    rescue Exception => err
      YtLog.info err
      flash[:error] = '上传数据失败'
    end
    flash[:notice] = '上传数据成功'
    redirect_to :action => 'upload'
  end
  
  def getnodes
    optype = params[:optype]
    word = params[:word]
    tasktimeid = params[:tasktimeid]
    meta = $TaskDesc[session[:task].strid]
    UnitFMTableData.set_table_name("ytapl_#{session[:task].strid}_#{meta.fmtable}".downcase)
    UnitFMTableData.reset_column_information
    
    units = Array.new
    if !params[:id]
      units = GetUnitForest(session[:task].id, session[:user].id)
    else
      units = UnitFMTableData.find(params[:id]).children
    end
    
    units.sort!
    
    doc = Document.new("<rows></rows>")
    if params[:id]
      doc.root.add_attributes({"parent"=> params[:id]})
    end
    
    for unit in units
      next if unit["display"] == "0"
      next if !includes?(session[:task].strid, tasktimeid, unit.unitid, optype, word) 
      row_node = doc.root.add_element(Element.new('row'))      
      attr = Hash.new
      attr['id'] = unit.unitid
      attr['open'] = '1' if !params[:id]
      attr['xmlkids'] = "1" if unit.children.size > 0
      row_node.add_attributes(attr)
            
      idnode = row_node.add_element(Element.new('cell'))
      idnode.text = unit.unitid
      idnode.add_attributes({"image"=>"../../../../img/icon_#{unit[meta.reporttype]}.gif"})
      
      row_node.add_element(Element.new('cell')).text = "<a target=_blank href='/main/getunitdata/#{unit.unitid}?taskTimeID=#{tasktimeid}'>" + unit[meta.unitname] + "</a>"
      
    
            
      #判断是否填了数
      filldate = ""
      filledStr = ""
      states = Ytfillstate.find(:all, :conditions => "taskid = '#{session[:task].strid}' and unitid = '#{unit.unitid}' and tasktimeid = #{tasktimeid}")
      if states.length == 0
	    filledStr = "<span class='style2'>否</span><span class='style2'>(启封)</span>"
	  else
	   filledStr = "<span class='style1'>是</span>"
	   state = states[0]
	   filldate = state.filldate.strftime("%Y-%m-%d %H:%M:%S")
	   if state.flag == 4
	     filledStr += "<span class='style2'>(启封)</span>"
	   elsif state.flag == 3
	     filledStr = "<span class='style2'>否</span><span class='style1'>(封存)</span>"
	   else
	     filledStr += "<span class='style1'>(封存)</span>"
	   end
	  end
	  row_node.add_element(Element.new('cell')).text = filledStr
	  row_node.add_element(Element.new('cell')).text = filldate
	  
	   #判断是否审核了
	   auditresult = ""
	   auditinfo = Ytauditinfo.find [unit.unitid, session[:task].strid, tasktimeid]
	   #auditinfo = auditinfos[0] if auditinfos.length > 0
	   if auditinfo
	     #auditstr = "<span class='style1'>#{auditinfo.flag==0 ? ('未审核'):('是')}</span>"
	     if auditinfo.auditor != ''
	       auditstr = "<span class='style1'>已审</span>"
	     else
	       auditstr = "<span class='style2'>未审</span>"
	     end
	     if auditinfo.flag == 1
	       auditresult = "<span class='style1'>已通过</span>"
	     else
	       auditresult = "<span class='style2'>未通过</span>"
	     end
	   else
	     auditstr = "<span class='style2'>否</span>" if !auditinfo
	   end
	   auditor = ""
	   auditor = auditinfo.auditor if auditinfo
	   auditdate = ""
	   auditdate = auditinfo.auditdate.strftime("%Y-%m-%d %H:%M:%S") if auditinfo
	   auditinfo = nil
	   
	   row_node.add_element(Element.new('cell')).text = auditstr
	   row_node.add_element(Element.new('cell')).text = auditdate
	   row_node.add_element(Element.new('cell')).text = auditor
	   row_node.add_element(Element.new('cell')).text = auditresult
	   
	   if states.size == 0
	     row_node.add_element(Element.new('cell')).text = "<a href='javascript:urge(\"#{unit.unitid}\")'>发送</a>"
	   end
     end
    
    xmlstr = ''
    doc.write(Output.new(xmlstr, "UTF-8"), -1)
    send_data xmlstr, :type =>"text/xml"
  end  
end
