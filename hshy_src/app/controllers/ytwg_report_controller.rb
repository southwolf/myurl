require "XMLHelper"
require "ReportEngine"

class YtwgReportController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @ytwg_reports = YtwgReport.paginate :page=>params[:page],  :per_page => 10, :order=>"id desc"
  end

  def show
    @ytwg_report = YtwgReport.find(params[:id])
  end

  def new
    @ytwg_report = YtwgReport.new
  end

  def create
    stream = params[:ytwg_report][:content]
    content = stream.read
    name = stream.original_filename[0, stream.original_filename.index(".")]
    if YtwgReport.find(:all, :conditions=>"name='#{name}'").size > 0
      flash[:error] = "存在同名查询模板，上传失败"
      render :action => 'new'
      return
    end
    
    report = YtwgReport.new(params[:ytwg_report])
    report.name = name
    report.content = content
    report.publisher = session[:user].truename
    report.publish_time = Time.new

    if report.save
      flash[:notice] = '上传报表模板成功'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @ytwg_report = YtwgReport.find(params[:id])
  end

  def update
    stream = params[:ytwg_report][:content]
    content = stream.read
    @ytwg_report = YtwgReport.find(params[:id])
    @ytwg_report.content = content
    @ytwg_report.publish_time = Time.new
    if @ytwg_report.save
      flash[:notice] = '更新模板成功.'
      redirect_to :action => 'list'
    else
      render :action => 'edit'
    end
  end

  def destroy
    YtwgReport.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
  
  def download
    @report = YtwgReport.find(params[:id])
    send_data EncodeUtil.change('GB2312', 'UTF-8', @report.content), :filename => @report.name+".xml"
  end
  
  def query
    engine = ReportEngine.new()
    helper = XMLHelper.new
    report = YtwgReport.find(params[:id])
    helper.Ruby_ReadFromXMLString(report.content)
    yttable = helper.tables[0]
    @sql = helper.parameters["sql"]  #"select * from ytwg_qjdjb"
    
    conditions = []
    conditions << "_state = '结束'" if params[:finished]
    conditions << "_madetime >= '#{params[:from]}'" if params[:from] && params[:from].size > 0
    conditions << "_madetime <= '#{params[:to]}'" if params[:to] && params[:to].size > 0
    conditions << "userid = #{params[:user]}" if params[:user] && params[:user].size > 0
    condition = conditions.join(" and ")
    @sql += " where " + condition if condition.size > 0
    
    table = engine.fill(helper.tables[0], @sql, helper.script)
    
    @style = helper.StyleToHTML(table)
    @tablehtml = helper.TableToEditHTML(table, helper.dictionFactory, {:script=>helper.script, :encoding=>"GB2312", :readonly=>true})
    
    render :layout=>"notoolbar_app"
  end
end
