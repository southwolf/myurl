# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

include ApplicationHelper

class ApplicationController < ActionController::Base
  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_TengWangGe_session_id'
  before_filter :check_user
  before_filter :check_right
  before_filter :configure_charsets
  before_filter :add_log
  
  def configure_charsets 
    response.headers["Content-Type"] = "text/html; charset=gb2312" 
  end
  
  #添加日志
  def add_log
    for key in $FilterMap.keys
      if request.path.index(key)
        log = YtwgEventlog.new
        log.time_occured = Time.new
        log.username = "#{session[:user].name}  #{session[:user].truename}"  if session[:user]
        log.description = $FilterMap[key]
        log.url = request.path
        log.ip = request.remote_ip
        log.save
        break
      end
    end
    true
  end
  
  def check_user
    if !session[:user]
      redirect_to :controller=>"login", :action=>"hehe_hehe"
      flash[:notice] = "请先登陆"
    end
  end
  
  def check_right
    for r in ["create","update","destroy", "edit", "new", "delete"]
      if self.action_name == r
        functions = YtwgFunction.find(:all, :conditions=>"controller_name like '/#{self.controller_name}%'")
        if functions.size > 0
          function = functions[0]      
          if function.edit_right && !checkright(YtwgRight.find(function.edit_right).name)
            redirect_to :controller=>"main", :action=>"no_right"
          end
        end
      end
    end
    
    
#    if (["create","update","destroy", "edit", "new"].include?(self.action_name))
#      functions = YtwgFunction.find(:all, :conditions=>"controller_name='#{self.controller_name}'")
#      if functions.size > 0
#        function = functions[0]      
#        if function.edit_right && !checkright(YtwgRight.find(function.edit_right).name)
#          redirect_to :controller=>"main", :action=>"no_right"
#        end
#      end
#    end
  end
  
  def rescue_action_in_public(exception)  
    render :partial => "share/error", :layout=>"application", :locals=>{:exception=>exception}
  end  
  
  #针对单表
  def to_single_pretty(controllername, editable=true, tablename=nil)
    tablename = controllername if !tablename
    funcs = YtwgFunction.find(:all, :conditions=>"controller_name = '#{controllername}'")
    if editable
      action = 'single_pretty_edit'
    else 
      action = 'single_pretty_show'
    end
    if funcs.size > 0
      if funcs[0].template && funcs[0].template.size > 0
        redirect_to :controller=>'main', :action=>action, :tablename=>tablename, :id=>params[:id], :function_id=> funcs[0].id
      end
    end
  end
  
  #针对主从表
  def to_double_pretty(controllername, args)
    tablename = args[:primary_tablename]||controllername
    editable  = args[:editable]
    float_tablename =args[:float_tablename]
    float_keyname   = args[:float_keyname]||'id'
    float_foreignkeyname = args[:float_foreignkeyname]||"#{tablename}_id"
    
    funcs = YtwgFunction.find(:all, :conditions=>"controller_name = '#{controllername}'")
    if editable
      action = 'double_pretty_edit'
    else 
      action = 'double_pretty_show'
    end
    if funcs.size > 0
      if funcs[0].template && funcs[0].template.size > 0
        redirect_to :controller=>'main', :action=>action, :tablename=>tablename, :id=>params[:id], 
         :function_id=> funcs[0].id, :float_tablename=>float_tablename, :float_keyname=>float_keyname,
         :float_foreignkeyname => float_foreignkeyname
      end
    end
  end
  
protected
	#为CTable填充值
  def set_table_data(table, record)
    for field in record.attribute_names
      rowcol = table.GetCellByFieldName(field)
      next if rowcol[0] == -1
      value = record[field]
      value = value.strftime("%Y-%m-%d") if value.kind_of?(Time)
      if value.kind_of?(TrueClass) || value.kind_of?(FalseClass)
        value = '1' if value.kind_of?(TrueClass)
        value = '0' if value.kind_of?(FalseClass)
      end
      table.SetCellValue(rowcol[0], rowcol[1], EncodeUtil.change("GB2312", "UTF-8", value.to_s))
    end
  end  
  
private
  def write_log(text)
    log = YtwgEventlog.new
    log.username = session[:user].name if session[:user]
    log.description = text
    log.time_occured = Time.new
    log.ip = request.remote_ip
    log.url = request.path
    log.save
  end
  
  def SetTableData(table, record)
    for field in record.attribute_names
      rowcol = table.GetCellByFieldName(field)
      next if rowcol[0] == -1
      value = record[field].to_s
      value = record[field].strftime("%Y-%m-%d") if record[field].class==Time 
      table.SetCellValue(rowcol[0], rowcol[1], EncodeUtil.change("GB2312", "UTF-8", value))
    end
  end  
end
