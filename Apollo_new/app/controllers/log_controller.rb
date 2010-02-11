class LogController < ApplicationController
  def index

  end 
 
  def list
    conditions = "1=1 "
    if params[:logtype].strip.size > 0
      conditions += " and eventtype in (#{params[:logtype]}) "
    end
    
    if params[:from].strip.size > 0
      conditions += " and timeoccured > '#{params[:from]}'"
    end
    
    if params[:to].strip.size > 0
      conditions += " and timeoccured < '#{params[:to]}'"
    end
    
    if params[:username].strip.size > 0
      conditions += " and username like '%#{params[:username]}%'"
    end
    
    if params[:memo].strip.size > 0
      conditions += " and memo like '%#{params[:memo]}%'"
    end
    
    if params[:source].strip.size > 0
      conditions += " and source like '%#{params[:source]}%'"
    end
  
    @total_dataevents=Ytdataevents.find(:all, :conditions=>conditions)
    @total_securityevents=Ytsecurityevents.find(:all, :conditions=>conditions)
    
    render :layout =>false
  end

  def dataevents_manage
    @ytdataeventss_pages, @ytdataeventss = paginate :ytdataeventss , :per_page => 20
  end

  def securityevents_manage
    @ytsecurityeventss_pages, @ytsecurityeventss = paginate :Ytsecurityeventss , :per_page => 20
  end
end
