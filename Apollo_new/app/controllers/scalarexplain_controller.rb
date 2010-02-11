#指标解释
require 'rexml/document'
class ScalarexplainController < ApplicationController  
  layout "main"
  def index
    @title = '指标解释'
  end
  
  
  def add_catalog
    explain = YtaplScalarexplain.new
    explain.name = params[:name]
    explain.reserved1 = params[:explaintype]
    explain.save
    flash[:notice] = "添加类别成功"
    redirect_to :action=>"index"
  end
  
  def modify_catalog
    explain = YtaplScalarexplain.find(params[:id])
    explain.name = params[:name]
    explain.save
    flash[:notice] = "修改类别成功"
    redirect_to :action=>"index"
  end
  
  def delete_catalog
    YtaplScalarexplain.find(params[:id]).destroy
    flash[:notice] = "删除类别成功"
    redirect_to :action=>"index"
  end
  
  def get_table_explain
    if params[:id]
      @catalogs = YtaplScalarexplain.find(:all, :conditions=>"id = #{params[:id]}")
    else
      @catalogs = YtaplScalarexplain.find(:all)
      @show_title=true
    end
    render :layout=>false
  end
  
  def save_explain
    @catalog = YtaplScalarexplain.find(params[:id])
    @catalog.content = params[:catalog]['content']
    @catalog.save
    redirect_to :action=>"get_table_explain", :id=>@catalog.id
  end
  
  def find_cell
    @catalogs = YtaplScalarexplain.find(:all, :conditions=>"content like '%#{params[:name]}%'")
    for catalog in @catalogs
      catalog.content = catalog.content.gsub(params[:name], "<span style='background-color=yellow'><b>#{params[:name]}</b></span>")
    end
    @show_title=true
    render :action=>'get_table_explain', :layout=>false
  end
  
  def get_all_catalogs
    doc = Document.new("<?xml version='1.0' encoding='gb2312'?><treeRoot></treeRoot>")
    catalogs = YtaplScalarexplain.find(:all, :conditions=>"reserved1 = '#{params[:id]}'")
    for catalog in catalogs
      newnode = doc.root.add_element(Element.new('tree'))
      attr = Hash.new
      attr['text'] = catalog.name
      attr['icon'] = "/img/icon_0.gif"
      attr['openIcon'] = "/img/icon_0.gif"
      attr['action'] = "javascript:selectCatalog(#{catalog.id});"
      
#      if !params[:target] || params[:target]==''
#        attr['clickFunc'] = "new Ajax.Updater('#{updatediv}', '#{sublink}/#{unit['unitid']}', {asynchronous:true}); return false;"
#      end
      attr['target'] = params[:target] if params[:target]!=""
      newnode.add_attributes(attr)
    end  
    
    xmlstr = ''
    
    doc.write(Output.new(xmlstr, "UTF-8"), -1)
    send_data xmlstr, :type =>"text/xml"    
  end
  
end
