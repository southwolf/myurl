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
      flash[:error] = "����ͬ�����������ϴ�ʧ��"
      render :action => 'new'
      return
    end
    
    @ytwg_workflow = YtwgWorkflow.new()
    @ytwg_workflow.name = name
    begin
      @ytwg_workflow.content = content
    rescue
      flash[:error] = "�ϴ��ļ��Ƿ�"
      render :action => 'new'
    end
    @ytwg_workflow.publish_time = Time.new
    if @ytwg_workflow.save
      FlowMeta.LoadWorkFlow(@ytwg_workflow.name, @ytwg_workflow.content.sub!('<?xml version="1.0" encoding="gb2312" ?>', ''))
      flash[:notice] = '��ӹ������ɹ�'
      redirect_to :action => 'list'
    else
      flash[:error] = "��ӹ�����ʧ��"
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
      flash[:error] = '�ϴ��ļ���ʽ�Ƿ�'
      render :action => 'edit'
      return
    end
    
    @ytwg_workflow.publish_time = Time.new
    if @ytwg_workflow.save
      FlowMeta.LoadWorkFlow(@ytwg_workflow.name, @ytwg_workflow.content, @ytwg_workflow.publish_time)
      flash[:notice] = '���¹������ɹ�'
      redirect_to :action => 'list'
    else
      flash[:notice] = '���¹�����ʧ��'
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
  
  #�ϴ�״̬�ڵ��¼�����
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
    flash[:notice] = "�ϴ�״̬����ɹ�"
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
  
  #�ϴ�����ģ��
  def upload_formtable
    stream = params[:content]
    content = stream.read
    helper = XMLHelper.new
    helper.ReadFromString(content)
    formtable = helper.tables[0]
    if !formtable
      flash[:notice] = "�ϴ��ļ���ʽ����"
      redirect_to :action=>"listinterface"
      return
    end
    conn = ActiveRecord::Base.connection
    conn.create_table "ytwg_#{formtable.GetTableID.downcase()}", :primary_key=>:id do |t|
      t.column "userid", :integer         #���̷����˵�id
      t.column "flowid", :integer         #��������id
      t.column "_remark", :integer         #ע��

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
    
    flash[:notice] = "����ɹ�"
    redirect_to :action=>"listinterface"
  end
  
  def delete_formtable
    flow = YtwgWorkflow.find(params[:id])
    conn = ActiveRecord::Base.connection
    conn.drop_table("ytwg_"+flow.formtable)
    flow.formtable = nil
    flow.save
    flash[:notice] = "ɾ������ɹ�"
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
  
  #����ҽ���������
  def flow_ibuild
    @ytwg_workflows = YtwgWorkflow.find(:all)
    @forms = Array.new
    for flow in @ytwg_workflows
      begin
      YtwgForm.set_table_name("ytwg_" + flow.formtable.downcase)
      rescue Exception=>err
        render :text=>"�����Ƿ��ϴ��˽���" 
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
      form_record._state = '��ʼ'
      state_name = form_record._state
    end
    
    states = []
    for state in form_record._state.split(',')
      states << state if checkright(state)
    end
    if states.size > 0
      state_name = states[0]
    else
      state_name = '��ʼ'
    end

    process = FlowProcess.new($Workflows[@flow.name], form_record, state_name)
    process.user = session[:user]
    process.signal_enter
    
    interfaces = YtwgStateinterface.find(:all, :conditions=>"flowid=#{@flow.id} and name = '#{state_name}'")
    if interfaces.size ==0
      render :text=>"û���ϴ���ʼ����"
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
      form._state = '��ʼ'
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
  
  #��ӡ���
  def print
    flow = YtwgWorkflow.find(params[:id])
    if !params[:forms]
      render :text=>"��û��ѡ���¼"
      return
    end
    
    params[:forms] = [ params[:forms] ] if params[:forms].class == String

    YtwgForm.set_table_name("ytwg_" + flow.formtable.downcase)
    YtwgForm.reset_column_information() 
    forms = YtwgForm.find(:all, :conditions=>"id in (#{params[:forms].join(',')})")
    if forms.size == 0
      render :text=>"��������û��ȡ����¼"
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
      render :text=>"��������û��ȡ������"
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
      render :text=>"û���ϴ�����������"
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
      form._state = "��ʼ"
      filename = @flow.name + ".xls"
    end
    interfaces = YtwgStateinterface.find(:all, :conditions=>"flowid=#{params[:flowid]} and name='#{form._state}'")
    if interfaces.size > 0
      helper = XMLHelper.new
      helper.ReadFromString(interfaces[0].content)
      SetTableData(helper.tables[0], form)
      send_file helper.ExportToExcel(helper.tables, helper.dictionFactory), :filename=>filename
    else
      render :text=>"û���ϴ�����������"
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
      form._state = "��ʼ"
     filename = @flow.name + ".pdf"
    end
    interfaces = YtwgStateinterface.find(:all, :conditions=>"flowid=#{params[:flowid]} and name='#{form._state}'")
    if interfaces.size > 0
      helper = XMLHelper.new
      helper.ReadFromString(interfaces[0].content)
      SetTableData(helper.tables[0], form)
      send_file helper.ExportToPDF(helper.tables, helper.dictionFactory), :filename=>filename
    else
      render :text=>"û���ϴ�����������"
    end
  end
  
  #�ȴ��Ҵ��������
  def show_waiting_form
    @forms = get_wait_form(params[:id])
    render :layout=>false
  end
  
  #��ʾ�ȴ��Ҵ�������б�
  def show_waiting_form_all
    @ytwg_workflows = YtwgWorkflow.find(:all)
    @forms = Array.new
    for flow in @ytwg_workflows
      @forms += get_wait_form(flow.id)
    end
    render :layout=>false
  end
  
  #��ʾ�Ҵ�����ı�
  def show_history
    @ytwg_workflows = YtwgWorkflow.find(:all)
    @forms = Array.new
    for flow in @ytwg_workflows
      historys = YtwgFormhistory.find(:all, :conditions=>"flowid=#{params[:id]} and userid=#{session[:user].id} and flowid=#{flow.id}")
      formids = Array.new
      formids =  historys.collect { |obj| obj.formid }
      formids << -1 if formids.size == 0
      
      if !flow.formtable || flow.formtable.size==0
        render :text=>"�����Ƿ��ϴ��˽���"
        return
      end
    
      YtwgForm.set_table_name("ytwg_" + flow.formtable.downcase)
      YtwgForm.reset_column_information() 
      @forms += YtwgForm.find(:all, :conditions=>"flowid=#{params[:id]} and userid<>#{session[:user].id} and id in (#{formids.join(',')})", :order=>"id desc")
    end
    render :layout=>false
  end
  
  #��ʾ�鵵���Ҵ��ı�
  def show_finished_history
    @ytwg_workflows = YtwgWorkflow.find(:all)
    @forms = Array.new
    for flow in @ytwg_workflows
      have_right = false
      for state in $Workflows[flow.name].states
        if state.name == "����" && checkright(state.right)
          have_right = true
        end
      end
      
      next if !have_right
      #      historys = YtwgFormhistory.find(:all, :conditions=>"flowid=#{flow.id}")
      #      formids = Array.new
      #      formids =  historys.collect { |obj| obj.id }
      #      formids << -1 if formids.size == 0
      
      if !flow.formtable || flow.formtable.size==0
        render :text=>"�����Ƿ��ϴ��˽���"
        return
      end
    
      YtwgForm.set_table_name("ytwg_" + flow.formtable.downcase)
      YtwgForm.reset_column_information() 
      @forms += YtwgForm.find(:all, :conditions=>"flowid=#{params[:id]} and _state = '����'", :order=>"id desc")
    end
    render :action=>"show_history", :layout=>false
  end
  
  def delete_a_form
    flow = YtwgWorkflow.find(params[:flow])
    YtwgForm.set_table_name("ytwg_" + flow.formtable.downcase)
    YtwgForm.reset_column_information() 
    YtwgForm.find(params[:id]).destroy
    flash[:notice] = "ɾ�����ɹ�"
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
  #�ж��û���ĳһ��״̬�Ƿ�ӵ��Ȩ��
  def check_state_right(form_name, state_name)
    for state in $Workflows[form_name].states
      if state.name == state_name
        return checkright(state.right)
      end
    end
    
    return false
  end
  
  #���ĳһ�ֵ��������еȴ���ǰ��½��������
  def get_wait_form(flowid)
    forms = []
    flow = YtwgWorkflow.find(flowid)
    if !flow.formtable || flow.formtable.size==0
      return forms
    end
    YtwgForm.set_table_name("ytwg_" + flow.formtable.downcase)
    YtwgForm.reset_column_information() 
    for state in $Workflows[flow.name].states
      next if state.name == "����"
      
      conditions = []
      conditions << "_state='#{state.name}'"
      
      #������ԴӶ��״̬ת�Ƶ����״̬����ȴ�����״̬��ִ�����״̬�ſ���ִ��
      if state.guest_trasits.size == 1      #ֻ���Դ�һ��״̬ת������
        conditions << " _state like '%,#{state.name}'"
        conditions << "_state like '#{state.name},%'"
      end

      if state.right == "�쵼"
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
