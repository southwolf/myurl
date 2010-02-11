#统计局公告
class StatisticreportController < ApplicationController
  layout "main"
  def index
  end
  
  def add_catalog
    catalog = YtaplStatisticcatalog.new
    catalog.parent_id = params[:catalog_id]
    catalog.name = params[:name]
    catalog.save
    redirect_to :action=>'index'
  end
  
  def show_catalog
    @catalog = YtaplStatisticcatalog.find(params[:id])
    #@reports = YtaplStatistic.find(:all, :conditions=>"cata_id = #{params[:id]}")
    @report_pages, @reports = paginate :YtaplStatistic, :per_page => 20, :conditions=>"cata_id = #{params[:id]}"
    render :layout=>false
  end
  
  def get_catalogs    
    doc = Document.new("<?xml version='1.0' encoding='gb2312'?><treeRoot></treeRoot>")
    catalogs = YtaplStatisticcatalog.find(:all, :conditions=>"parent_id = #{params[:id]} ")
    for catalog in catalogs
      newnode = doc.root.add_element(Element.new('tree'))
      attr = Hash.new
      if catalog.children.size > 0
        attr['src'] = "/statisticreport/get_catalogs/#{catalog.id}?target=report"
      end
      attr['text'] = catalog.name
      attr['icon'] = "/img/icon_0.gif"
      attr['openIcon'] = "/img/icon_0.gif"
      attr['action'] = "javascript:selectCatalog(#{catalog.id});"
      
      if !params[:target] || params[:target]==''
        attr['clickFunc'] = "new Ajax.Updater('#{updatediv}', '#{sublink}/#{unit['unitid']}', {asynchronous:true}); return false;"
      end
      #attr['target'] = params[:target] if params[:target]!=""
      newnode.add_attributes(attr)
    end  
    
    xmlstr = ''
    
    doc.write(Output.new(xmlstr, "UTF-8"), -1)
    send_data xmlstr, :type =>"text/xml"
  
  end
  
  def upload_file
    report = YtaplStatistic.new(params[:report])
    report.cata_id = params[:id]
    report.save
    flash[:notice] = "上传文件成功"
    redirect_to :action=>'show_catalog', :id=>params[:id]
  end
  
  def download_file
    file = YtaplStatistic.find(params[:id])
    send_file file.path
  end
  
  def delete_file
    report = YtaplStatistic.find(params[:id])
    cataid = report.cata_id
    report.destroy
    redirect_to :action=>'show_catalog', :id=>cataid
  end
  
  def find
    from = Time.mktime(params[:report]["from(1i)"], params[:report]["from(2i)"], params[:report]["from(3i)"])
    to = Time.mktime(params[:report]["to(1i)"], params[:report]["to(2i)"], params[:report]["to(3i)"])
    
    @catalog = YtaplStatisticcatalog.find(params[:id])
    @report_pages, @reports = paginate :YtaplStatistic, :per_page => 20, :conditions=>"cata_id = #{params[:id]} and uploadtime>='#{from.strftime('%Y-%m-%d')} 00:00:00' and uploadtime<='#{to.strftime('%Y-%m-%d')} 00:00:00' and name like '%#{params[:report][:name]}%'"
    render :action=>"show_catalog", :layout=>false
  end
end
