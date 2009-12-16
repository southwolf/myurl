require "workflow/FlowProcess"
require "workflow/FlowMeta"

class YtwgWorkflowController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
    :redirect_to => { :action => :list }

  def list
    #    @ytwg_workflow_pages, @ytwg_workflows = paginate :ytwg_workflows, :per_page => 10
    
    @ytwg_workflows = YtwgWorkflow.paginate(:per_page=>10, :page => params[:page], :order=>"position")
  end

  def oplist
    @ytwg_workflows = YtwgWorkflow.find(:all)
  end
  def show
    @ytwg_workflow = YtwgWorkflow.find(params[:id])
  end

  def new
    @ytwg_workflow = YtwgWorkflow.new
  end

  def create
    stream = params[:ytwg_workflow][:content]
    content = stream.read
    name = stream.original_filename[0, stream.original_filename.index(".")]
    if YtwgWorkflow.find(:all, :conditions=>"name='#{name}'").size > 0
      flash[:error] = "存在同名工作流，上传失败"
      render :action => 'new'
      return
    end
    
    @ytwg_workflow = YtwgWorkflow.new()
    @ytwg_workflow.name = name
    begin
      @ytwg_workflow.content = content
    rescue
      flash[:error] = "上传文件非法"
      render :action => 'new'
    end
    @ytwg_workflow.publish_time = Time.new
    if @ytwg_workflow.save
      FlowMeta.LoadWorkFlow(@ytwg_workflow.name, @ytwg_workflow.content.sub!('<?xml version="1.0" encoding="gb2312" ?>', ''))
      flash[:notice] = '添加工作流成功'
      redirect_to :action => 'list'
    else
      flash[:error] = "添加工作流失败"
      render :action => 'new'
    end
  end

  def edit
    @ytwg_workflow = YtwgWorkflow.find(params[:id])
  end

  def update
    stream = params[:ytwg_workflow][:content]
    content = stream.read
    @ytwg_workflow = YtwgWorkflow.find(params[:id])
    begin
      @ytwg_workflow.content = content
    rescue
      flash[:error] = '上传文件格式非法'
      render :action => 'edit'
      return
    end
    
    @ytwg_workflow.publish_time = Time.new
    if @ytwg_workflow.save
      FlowMeta.LoadWorkFlow(@ytwg_workflow.name, @ytwg_workflow.content, @ytwg_workflow.publish_time)
      flash[:notice] = '更新工作流成功'
      redirect_to :action => 'list'
    else
      flash[:notice] = '更新工作流失败'
      render :action => 'edit'
    end
  end
  
  def download
    @workflow = YtwgWorkflow.find(params[:id])
    send_data EncodeUtil.change('GB2312', 'UTF-8', @workflow.content), :filename => @workflow.name+".flo"
  end

  def destroy
    flow = YtwgWorkflow.find(params[:id])
    
    conn = ActiveRecord::Base.connection
    conn.drop_table "ytwg_#{flow.formtable}" rescue nil
    flow.destroy
    redirect_to :action => 'list'
  end
  
  def state_interface
    
  end
  
  def getstates
    #require 'EncodeUtil'
    doc = "<?xml version='1.0' encoding='UTF-8'?><treeRoot>"
    for state in $Workflows[YtwgWorkflow.find(params[:id]).name].states
      doc += "<tree text='#{state.name}' 
            clickFunc=\"new Ajax.Updater('editdiv', encodeURI('/ytwg_workflow/editinterface/#{params[:id]}?name=#{state.name}'), {asynchronous:true}); return false; \" 
            >"
      doc += "</tree>"
    end
    
    doc += '</treeRoot>'
    #doc = EncodeUtil.change('GB2312', 'UTF-8', doc)
    #p doc
    send_data doc, :type =>"text/xml"
  end
  
  def editinterface
    #render :text=>'hello'
    #render :action=> "edit"
  end
  
  def listinterface
    @flows = YtwgWorkflow.find(:all)
  end  
  
  #上传状态节点的录入界面
  def uploadinterface
    stream = params[:content]
    content = stream.read
    
    interfaces = YtwgStateinterface.find(:all, :conditions=>"flowid = #{params[:id]} and name = '#{params[:name]}'")
    if interfaces.size > 0
      interface = interfaces[0]
      interface.publish_time = Time.new
    else
      interface = YtwgStateinterface.new
      interface.flowid = params[:id]
      interface.name = params[:name]
      interface.publish_time = Time.new
    end
    interface.content = content  #EncodeUtil.change("UTF-8", "GB2312", content)
    interface.save
    flash[:notice] = "上传状态界面成功"
    redirect_to :action=>"listinterface"
  end
  
  def show_interface
    interface = YtwgStateinterface.find(params[:id])
    helper = XMLHelper.new
    helper.ReadFromString(EncodeUtil.change("GB2312", "UTF-8", interface.content))
    @style = helper.StyleToHTML(helper.tables[0])
    @html = helper.TableToEditHTML(helper.tables[0], helper.dictionFactory, 
      {:record=>@apply, :encoding=>"gb2312"})
  end
  
  #上传表定义模板
  def upload_formtable
    stream = params[:content]
    content = stream.read
    helper = XMLHelper.new
    helper.ReadFromString(content)
    formtable = helper.tables[0]
    if !formtable
      flash[:notice] = "上传文件格式错误"
      redirect_to :action=>"listinterface"
      return
    end
    conn = ActiveRecord::Base.connection
    conn.create_table "ytwg_#{formtable.GetTableID.downcase()}", :primary_key=>:id do |t|
      t.column "userid", :integer         #流程发起人的id
      t.column "flowid", :integer         #工作流的id
      t.column "_remark", :integer         #注释

      t.column "_state", :string, :limit=>30
      t.column "_madetime", :datetime
      t.column "_lastprocesstime", :datetime
          
      Integer(0).upto(formtable.GetRowCount()-1) do |row|
        next if formtable.IsEmptyRow(row)
        Integer(0).upto(formtable.GetColumnCount()-1) do |col|
          next if formtable.IsEmptyCol(col)
          cell = formtable.GetCell(row, col)
          next if !cell.IsStore || !cell.IsEffective
          next if formtable.GetCellDBFieldName(row, col).downcase == "id"
    	     
          
          if cell.GetDataType == 1    #CCell.CtNumeric
            t.column formtable.GetCellDBFieldName(row, col).downcase, :float
          elsif cell.GetDataType == 0    #CCell.CtText               
            if cell.IsCheckWidth()
              t.column formtable.GetCellDBFieldName(row, col).downcase, :string, {:limit=>cell.GetTextWidth}
            else
              t.column formtable.GetCellDBFieldName(row, col).downcase, :string, {:limit=>100}
            end     
          elsif cell.GetDataType == 3 #CCell.CtDate
            t.column formtable.GetCellDBFieldName(row, col).downcase, :datetime
          end     	     
        end
      end
    end
    
    flow = YtwgWorkflow.find(params[:id])
    flow.formtable = formtable.GetTableID
    flow.save
    
    flash[:notice] = "建表成功"
    redirect_to :action=>"listinterface"
  end
  
  def delete_formtable
    flow = YtwgWorkflow.find(params[:id])
    conn = ActiveRecord::Base.connection
    conn.drop_table("ytwg_"+flow.formtable)
    flow.formtable = nil
    flow.save
    flash[:notice] = "删除表定义成功"
    redirect_to :action=>"listinterface"
  end
  
  def myform
    @flows = YtwgWorkflow.find(:all, :order=>"position")
  end
  
  def myform1
    #@flows = YtwgWorkflow.find(:all)
    @flow = YtwgWorkflow.find(params[:id])
    render :layout=>false
  end
  
  #获得我建立的流程
  def flow_ibuild
    @ytwg_workflows = YtwgWorkflow.find(:all)
    @forms = Array.new
    for flow in @ytwg_workflows
      begin
      YtwgForm.set_table_name("ytwg_" + flow.formtable.downcase)
      rescue Exception=>err
        render :text=>"请检查是否上传了界面" 
        return
      end
      YtwgForm.reset_column_information() 
      @forms += YtwgForm.find(:all, :conditions=>"flowid=#{params[:id]} and userid = #{session[:user].id}", :order=>"id desc")
    end
    render :layout=>false
  end
  
  def write_form
    @flow = YtwgWorkflow.find(params[:flowid])
    YtwgForm.set_table_name("ytwg_" + @flow.formtable.downcase)
    YtwgForm.reset_column_information() 

    if params[:formid]
      form_record = YtwgForm.find(params[:formid])
      state_name = form_record._state
    else
      form_record = YtwgForm.new
      form_record._state = '开始'
      state_name = form_record._state
    end
    
    states = []
    for state in form_record._state.split(',')
      states << state if checkright(state)
    end
    if states.size > 0
      state_name = states[0]
    else
      state_name = '开始'
    end

    process = FlowProcess.new($Workflows[@flow.name], form_record, state_name)
    process.user = session[:user]
    process.signal_enter
    
    interfaces = YtwgStateinterface.find(:all, :conditions=>"flowid=#{@flow.id} and name = '#{state_name}'")
    if interfaces.size ==0
      render :text=>"没有上传开始界面"
      return
    end
    @start_interface = interfaces[0]
    helper = XMLHelper.new
    helper.ReadFromString(@start_interface.content)
    @style = helper.StyleToHTML(helper.tables[0])
    @html = helper.TableToEditHTML(helper.tables[0], helper.dictionFactory, 
      {:record=>form_record,:encoding=>"gb2312", :script=>helper.script})
    @historys = YtwgFormhistory.find(:all, :conditions=>"flowid=#{params[:flowid]} and formid = #{params[:formid]}") if params[:formid]
  end
  
  def update_form
    @flow = YtwgWorkflow.find(params[:id])
    YtwgForm.set_table_name("ytwg_" + @flow.formtable.downcase)
    YtwgForm.reset_column_information() 
    if params[:formid]
      form = YtwgForm.find(params[:formid])
      form.update_attributes(params[@flow.formtable])
      
      states = []
      for state in form._state.split(',')
        states << state if check_state_right(@flow.name, state)
      end
      state_name = states[0]
    else
      form = YtwgForm.new(params[@flow.formtable])
      form._madetime = Time.new
      form._state = '开始'
      state_name = form._state
      form.userid = session[:user].id
      form.flowid = @flow.id
    end

    form._lastprocesstime = Time.new    
    process = FlowProcess.new($Workflows[@flow.name], form, state_name)
    process.user = session[:user]
    process.signal_leave
    
    history = YtwgFormhistory.new
    history.userid = session[:user].id
    history.flowid = @flow.id
    history.formid = form.id
    history.process_time = Time.new
    history.remark = params[:remark]
    history.save
    redirect_to :action=>'myform', :id=>params[:id]
  end
  
  #打印表格
  def print
    flow = YtwgWorkflow.find(params[:id])
    if !params[:forms]
      render :text=>"您没有选择记录"
      return
    end
    
    params[:forms] = [ params[:forms] ] if params[:forms].class == String

    YtwgForm.set_table_name("ytwg_" + flow.formtable.downcase)
    YtwgForm.reset_column_information() 
    forms = YtwgForm.find(:all, :conditions=>"id in (#{params[:forms].join(',')})")
    if forms.size == 0
      render :text=>"发生错误，没有取到记录"
      return 
    end
    interfaces = YtwgStateinterface.find(:all, :conditions=>"flowid=#{params[:id]} and name='#{forms[0]._state}'")
    @htmls = []
    if interfaces.size > 0
      helper = XMLHelper.new
      helper.ReadFromString(interfaces[0].content)
      @style = helper.StyleToHTML(helper.tables[0])      
      for form in forms
        @htmls << helper.TableToEditHTML(helper.tables[0], helper.dictionFactory, 
          {:record=>form,:encoding=>"gb2312"})
      end
      render :layout=>"notoolbar_app"
    else
      render :text=>"发生错误，没有取到界面"
      return 
    end
  end
  
  def show_form
    @flow = YtwgWorkflow.find(params[:flowid])
    YtwgForm.set_table_name("ytwg_" + @flow.formtable.downcase)
    YtwgForm.reset_column_information() 
    form = YtwgForm.find(params[:formid])
     
    interfaces = YtwgStateinterface.find(:all, :conditions=>"flowid=#{params[:flowid]} and name='#{form._state.split(',')[0]}'")
    if interfaces.size > 0
      helper = XMLHelper.new
      helper.ReadFromString(interfaces[0].content)
      @style = helper.StyleToHTML(helper.tables[0])
      @html = helper.TableToEditHTML(helper.tables[0], helper.dictionFactory, 
        {:record=>form, :encoding=>"gb2312"})
      @historys = YtwgFormhistory.find(:all, :conditions=>"flowid=#{params[:flowid]} and formid = #{params[:formid]}")
    else
      render :text=>"没有上传工作流界面"
    end
  end
  
  def to_excel
    @flow = YtwgWorkflow.find(params[:flowid])
    YtwgForm.set_table_name("ytwg_" + @flow.formtable.downcase)
    YtwgForm.reset_column_information()
    begin
      form = YtwgForm.find(params[:id]) 
      filename = "#{@flow.name}-#{YtwgUser.find(form.userid).truename}.xls"
    rescue
      form = YtwgForm.new
      form._state = "开始"
      filename = @flow.name + ".xls"
    end
    interfaces = YtwgStateinterface.find(:all, :conditions=>"flowid=#{params[:flowid]} and name='#{form._state}'")
    if interfaces.size > 0
      helper = XMLHelper.new
      helper.ReadFromString(interfaces[0].content)
      SetTableData(helper.tables[0], form)
      send_file helper.ExportToExcel(helper.tables, helper.dictionFactory), :filename=>filename
    else
      render :text=>"没有上传工作流界面"
    end
  end
  
  def to_pdf
    @flow = YtwgWorkflow.find(params[:flowid])
    YtwgForm.set_table_name("ytwg_" + @flow.formtable.downcase)
    YtwgForm.reset_column_information() 
    begin
      form = YtwgForm.find(params[:id]) 
      filename = "#{@flow.name}-#{YtwgUser.find(form.userid).truename}.pdf"
    rescue
      form = YtwgForm.new
      form._state = "开始"
     filename = @flow.name + ".pdf"
    end
    interfaces = YtwgStateinterface.find(:all, :conditions=>"flowid=#{params[:flowid]} and name='#{form._state}'")
    if interfaces.size > 0
      helper = XMLHelper.new
      helper.ReadFromString(interfaces[0].content)
      SetTableData(helper.tables[0], form)
      send_file helper.ExportToPDF(helper.tables, helper.dictionFactory), :filename=>filename
    else
      render :text=>"没有上传工作流界面"
    end
  end
  
  #等待我处理的流程
  def show_waiting_form
    @forms = get_wait_form(params[:id])
    render :layout=>false
  end
  
  #显示等待我处理的所有表单
  def show_waiting_form_all
    @ytwg_workflows = YtwgWorkflow.find(:all)
    @forms = Array.new
    for flow in @ytwg_workflows
      @forms += get_wait_form(flow.id)
    end
    render :layout=>false
  end
  
  #显示我处理过的表单
  def show_history
    @ytwg_workflows = YtwgWorkflow.find(:all)
    @forms = Array.new
    for flow in @ytwg_workflows
      historys = YtwgFormhistory.find(:all, :conditions=>"flowid=#{params[:id]} and userid=#{session[:user].id} and flowid=#{flow.id}")
      formids = Array.new
      formids =  historys.collect { |obj| obj.formid }
      formids << -1 if formids.size == 0
      
      if !flow.formtable || flow.formtable.size==0
        render :text=>"请检查是否上传了界面"
        return
      end
    
      YtwgForm.set_table_name("ytwg_" + flow.formtable.downcase)
      YtwgForm.reset_column_information() 
      @forms += YtwgForm.find(:all, :conditions=>"flowid=#{params[:id]} and userid<>#{session[:user].id} and id in (#{formids.join(',')})", :order=>"id desc")
    end
    render :layout=>false
  end
  
  #显示归档在我处的表单
  def show_finished_history
    @ytwg_workflows = YtwgWorkflow.find(:all)
    @forms = Array.new
    for flow in @ytwg_workflows
      have_right = false
      for state in $Workflows[flow.name].states
        if state.name == "结束" && checkright(state.right)
          have_right = true
        end
      end
      
      next if !have_right
      #      historys = YtwgFormhistory.find(:all, :conditions=>"flowid=#{flow.id}")
      #      formids = Array.new
      #      formids =  historys.collect { |obj| obj.id }
      #      formids << -1 if formids.size == 0
      
      if !flow.formtable || flow.formtable.size==0
        render :text=>"请检查是否上传了界面"
        return
      end
    
      YtwgForm.set_table_name("ytwg_" + flow.formtable.downcase)
      YtwgForm.reset_column_information() 
      @forms += YtwgForm.find(:all, :conditions=>"flowid=#{params[:id]} and _state = '结束'", :order=>"id desc")
    end
    render :action=>"show_history", :layout=>false
  end
  
  def delete_a_form
    flow = YtwgWorkflow.find(params[:flow])
    YtwgForm.set_table_name("ytwg_" + flow.formtable.downcase)
    YtwgForm.reset_column_information() 
    YtwgForm.find(params[:id]).destroy
    flash[:notice] = "删除表单成功"
    redirect_to :action=>"myform"
  end
  
  def reorder
    @workflows = YtwgWorkflow.find(:all, :order=>"position")
    render :layout=>"notoolbar_app"
  end
  
  def order
    index = 1
    for node in params[:nodelist]
      child = YtwgWorkflow.find(node)
      child.position = index
      child.save
      index += 1
    end
  end
  
  def graph
    require "GraphGenerator"
    workflow = YtwgWorkflow.find(params[:id])
    g = GraphGenerator.new
    file = g.generate(workflow.content, workflow.id.to_s)
    render :text=>"<img src='#{file.sub(/public/, "")}'>"
  end
  
  def graph_vml
    @workflow = YtwgWorkflow.find(params[:id])
    render :layout=>false
  end
  
private
  #判断用户在某一个状态是否拥有权限
  def check_state_right(form_name, state_name)
    for state in $Workflows[form_name].states
      if state.name == state_name
        return checkright(state.right)
      end
    end
    
    return false
  end
  
  #获得某一种单据中所有等待当前登陆者审批的
  def get_wait_form(flowid)
    forms = []
    flow = YtwgWorkflow.find(flowid)
    if !flow.formtable || flow.formtable.size==0
      return forms
    end
    YtwgForm.set_table_name("ytwg_" + flow.formtable.downcase)
    YtwgForm.reset_column_information() 
    for state in $Workflows[flow.name].states
      next if state.name == "结束"
      
      conditions = []
      conditions << "_state='#{state.name}'"
      
      #如果可以从多个状态转移到这个状态，则等待所有状态都执行完此状态才可以执行
      if state.guest_trasits.size == 1      #只可以从一个状态转到这里
        conditions << " _state like '%,#{state.name}'"
        conditions << "_state like '#{state.name},%'"
      end

      if state.right == "领导"
        all_forms = YtwgForm.find(:all, :conditions=>conditions.join(' or '), :order=>"id desc")
        for form in all_forms
          forms << form if YtwgUser.find(form.userid).department.leader_id == session[:user].id rescue nil
        end
      else
        for right in state.right.split(',')
          if checkright(right)
            forms += YtwgForm.find(:all, :conditions=>conditions.join(' or '), :order=>"id desc")
          end
        end
      end
    end
    forms.uniq!
    return forms
  end
end
