# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
require 'iconv'
require 'rexml/document'
require 'unit'
require 'base64'

include ApplicationHelper

class ApplicationController < ActionController::Base
  before_filter :login
  
  #登陆验证
  def login
    if !session[:user]
      flash[:notice] = "请先登陆"
      redirect_to :controller=>'login', :action=>'index' 
    end
  end
  
  def log_error(exception) 
    super(exception)
    
    file = File.new('log/error.log', 'a')
    file << exception.to_s
    file << exception.backtrace
    file << "\n\n"
    file.close
  end

  

#############日志########################  
  ERROR = 0
  WARNING = 1
  INFO = 2
  AUDIT_SUCCESS = 3
  AUDIT_FAIL = 4
  #安全事件日志
  #logtype:整数，memo:字符串
  def SecurityLog(logtype, memo)
    event = Ytsecurityevents.new
    event.timeoccured = Time.new
    event["type"] = logtype
    event.source = request.env_table["REMOTE_ADDR"]
    event.username = session[:user].name if session[:user]
    event.memo = memo
    event.save
  end
  
  #数据事件日志
  #logtype:整数，memo:字符串
  def DataLog(logtype, memo)
    event = Ytdataevents.new
    event.timeoccured = Time.new
    event["type"] = logtype
    event.source = request.env_table["REMOTE_ADDR"]
    event.username = session[:user].name if session[:user]
    event.memo = memo
    event.save
  end
  
  #未知网址
  def unknown_request
  end  
  
###################单位树回调 为了考虑与rails1.2兼容，此功能已经转移到unittree_controller中去###################3  
  def getchildunit  
    parent = params[:id]
    sublink = params[:sublink]
    updatediv = params[:updatediv]     
    target = params[:target]
    doc = Document.new("<?xml version='1.0' encoding='gb2312'?><treeRoot></treeRoot>")
    taskmeta = $TaskDesc[session[:task].strid]
    Unit.set_table_name("ytapl_#{taskmeta.taskid}_#{taskmeta.fmtable}".downcase)
    units = Unit.find(:all, :conditions =>"p_parent = '#{parent}'")
    units.sort!
    for unit in units
      next if params[:showhidden]!="true" && unit["display"].to_s == '0'
      
      #判断读权限
      #next if CheckUnitRight(session[:task].taskid, session[:user].id, unit.unitid) == 0
      #是单户企业且用户没有权限      
      if ['0','1'].include?(unit.unitid[unit.unitid.size-1,1]) && !CheckRight(session[:user].id, "查看底层单位数据")
        next
      end
      
      newnode = doc.root.add_element(Element.new('tree'))
      attr = Hash.new
      attr['text'] = unit[taskmeta.unitname]
      if Unit.find(:all, :conditions => "p_parent = '#{unit.unitid}'").length > 0
        attr['src'] = "/application/getchildunit/#{unit['unitid']}?sublink=#{sublink}&updatediv=#{updatediv}&target=#{target}&showhidden=#{params[:showhidden]}"
      end
      attr['icon'] = "/img/icon_#{unit[taskmeta.reporttype]}.gif"
      attr['openIcon'] = "/img/icon_#{unit[taskmeta.reporttype]}.gif"
      attr['checkValue'] = unit["unitid"]
      #print "\n-----------------sublink is --------------------\n"

      if sublink && sublink.length > 0
        attr['action'] = "#{sublink}/#{unit['unitid']}"
      else
        attr['action'] = "javascript:void(0)"
      end
      
      if !params[:target] || params[:target]==''
        attr['clickFunc'] = "new Ajax.Updater('#{updatediv}', '#{sublink}/#{unit['unitid']}', {asynchronous:true}); return false;"
      end
      attr['target'] = target if params[:target]!="" && target
      newnode.add_attributes(attr)
    end  
    
    xmlstr = ''
    
    doc.write(Output.new(xmlstr, "UTF-8"), -1)
    #print EncodeUtil.change("GB2312", "UTF-8",xmlstr)
    send_data xmlstr, :type =>"text/xml"
  end
  
  ###########代码字典树回调###为了考虑与rails1.2兼容，此功能已经转移到unittree_controller中去###############
  def getdiction
    doc = Document.new("<?xml version='1.0' encoding='gb2312'?><treeRoot></treeRoot>")
    meta = $TaskDesc[session[:task].strid]
    dict = meta.helper.dictionFactory.GetDictionByID(params[:diction])
    parent = params[:pre].to_s || ""
    (parent.length-1).downto(0) do |i|
	   if parent[i] == 48
		parent[i] = ''
       else
        break
	   end
	end

    levels = dict.Levels.split(',')
    levels << dict.Length if levels.size == 0
    
    if parent.size > 0
	 for level in levels
	   if level.to_i >= parent.size
	     parent = parent.ljust(level.to_i, '0')
	     break
	   end
	 end
	end
	
    for level in levels
      if level.to_i > parent.size
        items = dict.GetAllItems()
        keys = items.keys
        keys.sort!
        for item in keys
          value = items[item]
          if item[level.to_i, dict.Length-level.to_i] == "0"*(dict.Length-level.to_i) && parent == item[0, parent.size] && (item[parent.size, dict.Length-parent.size] != "0"*(dict.Length-parent.size) || item=='0'*item.size())
            newnode = doc.root.add_element(Element.new('tree'))
            attr = Hash.new
            attr['text'] = value
            if level.to_i < dict.Length
              attr['src'] = "/application/getdiction?pre=#{item}&diction=#{params[:diction]}&cellname=#{params[:cellname]}"
            end
            attr['icon'] = "/img/icon_0.gif"
            attr['openIcon'] = "/img/icon_0.gif"
            
            copyindex = item.size
            (item.size-1).downto(0) do |i|
	          if item[i] != 48
                copyindex = i+1
                break
	          end
	        end
	        likeitem = item[0, copyindex]	        
            attr['checkValue'] = "#{params[:cellname]} like '#{likeitem}%'"
            attr['kind'] = 'dict'
            newnode.add_attributes(attr)
          end
        end    
        break
      end
    end    
    
    xmlstr = ''    
    doc.write(Output.new(xmlstr, "UTF-8"), -1)
    send_data xmlstr, :type =>"text/xml"
  end
  
  def ZipAndBase64(text)
    f = open('tmp/temp.zip', 'wb')
    gz = Zlib::GzipWriter.new(f)
    gz.write text
    gz.close
    
    file = File.new('tmp/temp.zip', "rb")
    stream = file.read()
    stream = Base64.b64encode(stream).gsub("\n", "")
    file.close
    
    File.delete('tmp/temp.zip')
    
    stream
  end
  
  def DecodeZipAndBase64(text)
    zipstream = Base64.decode64(text)
    f = open('tmp/temp.zip', 'wb')
    f << zipstream
    f.close
    
    Zlib::GzipReader.open('tmp/temp.zip') {|gz|
      return gz.read
    }
  end

  #获得一个任务的默认任务时间
  #taskid 是任务的id，数字，唯一标识，返回Yttasktime对象
  def GetDefaultTaskTime(taskid)
    tasktimes = Yttasktime.find(:all, :conditions => "taskid = #{taskid}", :order=>"tasktimeid")
    first = tasktimes[0]
    
    now = Time.new
    if first.endtime.month - first.begintime.month > 10 #年报
      for tasktime in tasktimes
        return tasktime if now.year-tasktime.begintime.year==1
      end
    elsif first.endtime.month - first.begintime.month >2 #季报
      for tasktime in tasktimes
        return tasktime if (now.year==tasktime.begintime.year && now.month - tasktime.begintime.month<=6 && now.month - tasktime.begintime.month>=36) || (now.year==tasktime.begintime.year+1 && now.month+12 - tasktime.begintime.month<=6 && now.month+12 - tasktime.begintime.month>=36)
      end
    elsif first.endtime.mday - first.begintime.mday > 27 #月报
      for tasktime in tasktimes
        return tasktime if now.at_beginning_of_month.last_month == tasktime.begintime
      end    
    end
    
    tasktimes[0]
  end

  
  #从数据库中读取一个任务，一个单位，一个时间的所有数据
  #返回一个array，存放的是ActiveRecord::Base实例
  def _GetUnitData(taskstrid, unitid, tasktimeid, getempty=true, onlysum=false)    
    meta = $TaskDesc[taskstrid]
    helper = meta.helper
    
    result = Array.new
    
    return result if !unitid
    
    count = 0
    for table in helper.tables
      #如果表不汇总则不取
      if onlysum && table.GetProperty('SumTable') != '1'
        count += 1
        next 
      end
      
      if count == 0
        UnitFMTableData.set_table_name("ytapl_#{taskstrid}_#{table.GetTableID()}".downcase)
        UnitFMTableData.reset_column_information
        
        begin
        	unitdata = UnitFMTableData.find(unitid)
        rescue
        	return result
        end
      else
        UnitTableData.set_table_name("ytapl_#{taskstrid}_#{table.GetTableID()}".downcase)
        UnitTableData.reset_column_information        
        
        begin
          unitdata = UnitTableData.find [unitid, tasktimeid]
        rescue  
          if !getempty  #返回空结果
            return Array.new
            #next
          end
          unitdata = UnitTableData.new
          unitdata.unitid = unitid
          unitdata.tasktimeid = tasktimeid
        ensure
          if !unitdata
            unitdata = UnitTableData.new 
            unitdata.unitid = unitid
            unitdata.tasktimeid = tasktimeid
          end
        end
        
        unitdata.get_typed_value()
      end
      
      result << unitdata
      count += 1
    end
    result
  end
  
  #获得单位, falg,#0：选中节点，1：选中节点和直接下级节点，2：选中节点和全部下级节点
  #返回一个array，存放的是ActiveRecord::Base实例
  def GetUnits(taskstrid, unitids, flag)
    result = Array.new    
    
    meta = $TaskDesc[taskstrid]
    UnitFMTableData.set_table_name("ytapl_#{taskstrid}_#{meta.helper.tables[0].GetTableID()}".downcase)
    UnitFMTableData.reset_column_information    
    for unitid in unitids
      theunit = UnitFMTableData.find(unitid)
      result << theunit if theunit
    end
    
    return result if flag == "0"
    
    if flag == "1"
      for unitid in unitids
        children = UnitFMTableData.find(:all, :conditions => "p_parent = '#{unitid}'")
        for child in children
          include = false
          for unit in result
            if unit.unitid == child.unitid
              include = true
              break
            end
          end
          result << child if !include
        end
      end
    elsif flag == "2"
      for unitid in unitids
        children = UnitFMTableData.find(:all, :conditions => "p_parent = '#{unitid}'")
        for child in children
          include = false
          for unit in result
            if unit.unitid == child.unitid
              include = true
              break
            end
          end
          result << child if !include
        
          #对每个child查找是否有子节点，有的话递归调用
          grandsons = UnitFMTableData.find(:all, :conditions => "p_parent = '#{child.unitid}'")
          for grandson in grandsons
            units = GetUnits(taskstrid, grandson.unitid, flag)
            for unit in units
              result << unit
            end
          end
        end
      end
    end
    
    result
  end
end