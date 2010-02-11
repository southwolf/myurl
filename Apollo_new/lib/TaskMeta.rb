require "XMLHelper"
require "EncodeUtil"
require "base64"
require "sys/cpu"
require 'digest/md5'
include Sys
      
class TaskMeta
  attr_accessor :taskid, :fmtable, :unitcode, :unitname, :parentunit, :reporttype, :headquater, :view, :helper
  def initialize()
    @taskid = ""
    @fmtable = ""
    @unitcode = ""
    @unitname = ""
    @parentunit = ""
    @reporttype = ""
    @headquater = ""
    @view = ""
    @helper = XMLHelper.new
  end
  
  def to_s
    return "TaskMeta: taskid:#{@taskid}, fmtable:#{@fmtable}, unitcode:#{unitcode}, unitname:#{@unitname}, parentunit:#{@parentunit}, reporttype:#{@reporttype}, headquater:#{@headquater}"
  end

 class << self
  def LoadAllTask
    $TaskDesc.clear
    #begin
      tasks = Task.find(:all, :limit=>$TASK_MAX)
    for task in tasks
      LoadTask(task.id)
    end  
    #rescue Exception=>err
    #	YtLog.info err.to_s
    #end
  end
  
  def LoadTask(id)
      #检查软件安装合法性
      if !Check()
        YtLog.info "软件没有得到中普友通公司授权，属于非法安装，退出";
 #       exit!(0)
 #       return
      end
      
      task = Task.find(id)
    
      YtLog.info task.strid
      
      taskmeta = TaskMeta.new
      taskmeta.taskid = task.strid
      taskmeta.view = task.view
      
      #str = EncodeUtil.change("GB2312", "UTF-8", task.view)   
      #taskmeta.helper.ReadFromString(str)
      if $OS == "UNIX"
        str = task.view
        taskmeta.helper.Ruby_ReadFromXMLString(str)
      elsif $OS == "WINDOWS"
        str = EncodeUtil.change("GB2312", "UTF-8", task.view)   
        taskmeta.helper.ReadFromString(str)
      end
      
      prop = taskmeta.helper.parameters
      taskmeta.fmtable = taskmeta.helper.tables[0].GetTableID()
      taskmeta.unitcode = prop['DWDM']
      taskmeta.unitname = prop['DWMC']
      taskmeta.parentunit = prop['SJDM']
      taskmeta.reporttype = prop['BBLX']
      taskmeta.headquater = prop['JTDM']
      
      
      $TaskDesc[taskmeta.taskid] = taskmeta
      
  end
  
  def Remove(key)
    $TaskDesc.delete(key)
  end
  
  def Check()
    begin
      
      id = 'AF2BCCG34DZE309EFWG'
      begin
      	CPU.processors{ |cs|
        	id = id + cs.processor_id + "G8765er"
      	}
      rescue
      	id += CPU.cpu_mhz.to_s + CPU.flags.to_s
      end
      id = id + "2K23W2344ZG"
      
      digest = Digest::MD5.new
      digest << Base64.encode64(id)
      id = digest.hexdigest
      id = Base64.encode64(id)
      #生成标识文件
      iden_file = File.new("identify.txt", "w")
      iden_file << id
      iden_file.close
    
      #检查序列号文件
      lisense_file = File.new("sn.txt", "r") rescue nil
      return false if !lisense_file
      sn_text = lisense_file.read()
      
      enc_id = Base64.encode64(id)
      enc_id[1]='L'
      enc_id[5]='M'
      enc_id[8]='X'
      digest = Digest::MD5.new
      digest << Base64.encode64(enc_id)
      if sn_text == digest.hexdigest
        return true
      end
      return false
    rescue Exception=>err
      p err
      return false
    end
  end
  
 end
end