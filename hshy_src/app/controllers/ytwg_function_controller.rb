class YtwgFunctionController < ApplicationController
  def index
    #list
    #render :action => 'list'
    @roots = YtwgFunction.find(:all, :conditions=>"parent_id is null or parent_id=''")
    render :layout=>"notoolbar_app"
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @ytwg_function_pages, @ytwg_functions = paginate :ytwg_functions, :per_page => 10
  end

  def show
    @ytwg_function = YtwgFunction.find(params[:id])
  end

  def new
    @ytwg_function = YtwgFunction.new
    @ytwg_function.parent_id = params[:parent]
    render :layout=>false
  end

  def create
    @ytwg_function = YtwgFunction.new(params[:ytwg_function])
    if @ytwg_function.save
      flash[:notice] = '新建节点成功'
      redirect_to :action => 'index'
    else
      render :action => 'new'
    end
  end

  def edit
    @ytwg_function = YtwgFunction.find(params[:id])
    render :action => "edit", :layout =>false
  end

  def update
    @ytwg_function = YtwgFunction.find(params[:id])
    if @ytwg_function.update_attributes(params[:ytwg_function])
      flash[:notice] = '修改节点信息成功'
      redirect_to :action => 'index'
    else
      render :action => 'edit'
    end
  end

  def destroy
    YtwgFunction.find(params[:id]).destroy
    redirect_to :action => 'index'
  end
  
  def getchildnode
    require 'EncodeUtil'
    doc = "<?xml version='1.0' encoding='UTF-8'?><treeRoot>"
  
    parent = YtwgFunction.find(params[:id])
    for child in parent.children
      src = "/ytwg_function/getchildnode/#{child.id}"
      src = "" if child.children.size == 0
      img = "/img/icon_9.png"
      img = "/img/icon_0.png" if child.children.size == 0
      doc += "<tree text='#{child.text}' 
              src='#{src}' 
              icon='#{img}' 
              openIcon='#{img}' 
              clickFunc=\" new Ajax.Updater('editdiv', '/ytwg_function/edit/#{child.id}', {asynchronous:true}); return false; \"
              >"
      doc += "</tree>"
    end
    
    doc += '</treeRoot>'
    doc = EncodeUtil.change('UTF-8', 'GB2312', doc)
    send_data doc, :type =>"text/xml"
  end
  
  def getchildnode_action
    doc = "<?xml version='1.0' encoding='UTF-8'?><treeRoot>"
  
    parent = YtwgFunction.find(params[:id])
    for child in parent.children
      next if child.hide == 1
      next if child.list_right && child.list_right.size > 0 && !checkright(YtwgRight.find(child.list_right).name)
      src = "/ytwg_function/getchildnode_action/#{child.id}"
      src = "" if child.children.size == 0
      action = "#{child.controller_name}"
#      action = "/#{child.controller_name}/#{child.action_name}"
#      action = "" if !child.controller_name || child.controller_name==''
      img = "/img/icon_9.png"
      img = "/img/icon_0.png" if child.children.size == 0
      doc += "<tree text='#{child.text}' 
              src='#{src}' 
              icon='#{img}' 
              openIcon='#{img}' 
              action='#{action}'
              target='content'
              >"
      doc += "</tree>"
    end
    
    doc += '</treeRoot>'
    doc = EncodeUtil.change('UTF-8', 'GB2312', doc)
    send_data doc, :type =>"text/xml"
  end
  
  def reorder
    @node = YtwgFunction.find(params[:id])
    render :layout=>"notoolbar_app"
  end
  
  def order
    index = 1
    for node in params[:nodelist]
      child = YtwgFunction.find(node)
      child.position = index
      child.save
      index += 1
    end
    
    render :text=>'排序成功'
  end
  
  def uploadtemplate
    p params
    stream = params[:file]
    xmlstr = stream.read
    if xmlstr.size > 0
      function = YtwgFunction.find(params[:id])
      function.template = EncodeUtil.change("UTF-8", "GB2312", xmlstr)
      function.save
      flash[:notice] = '发布模板成功'
    end
    redirect_to :action=>"index", :id=>params[:id]
  end
end
