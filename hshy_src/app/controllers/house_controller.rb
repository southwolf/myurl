class HouseController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @house_pages, @houses = paginate :houses, :per_page => 10
  end
  
  def sell_list
    log = Viewlog.find(:first, :conditions=>"user_id=#{session[:user].id} ")
    if log
      houes = nil
      house = House.find(log.house_id) rescue nil
      if house
        redirect_to :action=>'show', :id=>house
        return
      end 
    end
    
    ids = session[:user].department.quyus.collect{ |q|
      q.id
    }
    ids << -1
    
    ids = ids.join(',')
    
   @houses1 = House.paginate  :page=>params[:page], :per_page => 20, :order=>"id desc", :conditions=>"tag=1 and ku = 1 and quyu_id in (#{ids})"
   @houses2 = House.paginate  :page=>params[:page], :per_page => 20, :order=>"id desc", :conditions=>"tag=1 and ku = 2 and quyu_id in (#{ids})"
   @houses3 = House.paginate  :page=>params[:page], :per_page => 20, :order=>"id desc", :conditions=>"tag=1 and ku = 3 and quyu_id in (#{ids})"
   @houses4 = House.paginate  :page=>params[:page], :per_page => 20, :order=>"id desc", :conditions=>"tag=1 and ku = 4 and quyu_id in (#{ids})"
   @tag = 1
   render :action=>'list' 
  end
  
  def rent_list
    log = Viewlog.find(:first, :conditions=>"user_id=#{session[:user].id} ")
    if log
      houes = nil
      house = House.find(log.house_id) rescue nil
      if house
        redirect_to :action=>'show', :id=>house
        return
      end 
    end
    
    ids = session[:user].department.quyus.collect{ |q|
      q.id
    }
    ids << -1
    
    ids = ids.join(',')

    @houses1 = House.paginate  :page=>params[:page], :per_page => 20, :order=>"id desc", :conditions=>"tag=2 and ku = 1 and quyu_id in (#{ids})"
    @houses2 = House.paginate  :page=>params[:page], :per_page => 20, :order=>"id desc", :conditions=>"tag=2 and ku = 2 and quyu_id in (#{ids})"
    @houses3 = House.paginate  :page=>params[:page], :per_page => 20, :order=>"id desc", :conditions=>"tag=2 and ku = 3 and quyu_id in (#{ids})"
    @houses4 = House.paginate  :page=>params[:page], :per_page => 20, :order=>"id desc", :conditions=>"tag=2 and ku = 4 and quyu_id in (#{ids})"
    
    @tag = 2
    render :action=>'list'
  end

  def show
    log = Viewlog.find(:first, :conditions=>"user_id=#{session[:user].id} ")
    if log
      @houes = nil
      @house = House.find(log.house_id) rescue nil
      if @house
        @houselogs = Houselog.find(:all, :conditions=>"house_id=#{params[:id]}", :limit=>5, :order=>"id desc")
        @houselog = Houselog.new
        flash[:notice] = "注意：您之前查询的房源没有填写跟进记录"
        return
      end 
    end
    
    @house = House.find(params[:id])
    if !checkright("查看房源核心信息")
    	flash[:notice] = "您无权查看房源信息"
    	if @house.tag == 1
    		redirect_to :action=>"sell_list"
    	else
    		redirect_to :action=>"rent_list"
    	end
    	return
    end
    
    params[:password] = params[:password] || ""

    if @house.secret == 1       #是私盘
      if @house.secrettag == 1          #是永久私盘
        if params[:password] != @house.password
          flash[:notice] = "请输入正确密码"
          render :action=>"password", :id=>params[:id]
          return
        elsif (!params[:password] || params[:password].size == 0)   #需要输入密码
          redirect_to :action=>"password", :id=>params[:id]
          return
        end
      else    #不是永久私盘
        if @house.password.to_s.size > 0 && @house.inputtime.tomorrow.tomorrow > Time.new  #没有定为永久私盘，有密码，录入时间在2天之内，需要密码验证  
          if params[:password] != @house.password
            flash[:notice] = "请输入正确密码"
            render :action=>"password", :id=>params[:id]
            return
          elsif (!params[:password] || params[:password].size == 0)   #需要输入密码
            redirect_to :action=>"password", :id=>params[:id]
            return
          end
        end
      end
    end

#
#    if @house.secret == 1  && @house.password.to_s.size > 0 && (!params[:password] || params[:password].size == 0)
#      redirect_to :action=>"password", :id=>params[:id]
#      return
#    elsif @house.secret == 1 && @house.password.to_s.size > 0 && params[:password] != @house.password
#      flash[:notice] = "密码错误，请重试"
#      render :action=>"password", :id=>params[:id]
#      return
#    end
    
    flash[:notice] = "看完房源信息后请填写跟进记录"
    logs = Viewlog.find(:all, :conditions=>"user_id=#{session[:user].id} and house_id <> #{params[:id]}")
    if logs.size > 0
      house = House.find(logs[0]) rescue nil
      if house
        if house.tag == 1
          flash[:notice] = "房源 #{house.name} 跟进信息没完成,无法查看房源信息"
          redirect_to :action=>"sell_list"
        else
          flash[:notice] = "房源 #{house.name} 跟进信息没完成,无法查看房源信息"
          redirect_to :action=>"rent_list"
        end
        return
      end 
    end
    
    viewlog = Viewlog.new
    viewlog.user_id = session[:user].id
    viewlog.house_id = params[:id]
    viewlog.visittime = Time.new
    viewlog.save
    
    @houselogs = Houselog.find(:all, :conditions=>"house_id=#{params[:id]}", :limit=>5, :order=>"id desc")
    @houselog = Houselog.new
  end
  
  
  def password
    @house = House.find(params[:id])  
  end

  def new
    @house = House.new
    @house.tag = params[:tag]
  end

  def create
    @house = House.new(params[:house])
    if @house.xq.to_s.size == 0 || @house.d.to_s.size == 0 || @house.danyuan.to_s.size == 0 || @house.h.to_s.size == 0
      flash[:notice] = '添加房源失败，请填写房屋地址详细信息.'
      render :action => 'new'
      return
    end
    @house.inputer = session[:user].truename
    @house.inputtime = Time.new
    if House.count("xq='#{@house.xq}' and d='#{@house.d}' and danyuan=#{@house.danyuan} and  h=#{@house.h} and tag=#{@house.tag}") >0
      flash[:notice] = '添加房源失败，有重复房源.'
      render :action => 'new'
      return
    end
    if @house.save
      flash[:notice] = '添加房源成功.'
      if @house.tag == 1
        redirect_to :action => 'sell_list'
      else
        redirect_to :action => 'rent_list'
      end
    else
      render :action => 'new'
    end
  end

  def edit
    @house = House.find(params[:id])
  end

  def update
    @house = House.find(params[:id])
    @house.update_attributes(params[:house])
    flash[:notice] = "更改成功"
    write_log("修改房源信息或移库，房源id:#{@house.id}")
    if @house.tag == 1
        redirect_to :action => 'sell_list'
      else
        redirect_to :action => 'rent_list'
      end
  end

  def destroy
    house = House.find(params[:id])
    if house.tag == 1
      redirect_to :action => 'sell_list'
    else
      redirect_to :action => 'rent_list'
    end
    house.destroy
  end
  
  def query
    conditions = []
    conditions << "ku=1"
    conditions << "id=#{params[:id]}" if params[:id].size > 0
    conditions << "tag=#{params[:tag]}" if params[:tag].size > 0
    conditions << "quyu_id=#{params[:quyu]}" if params[:quyu].size > 0
    conditions << "s='#{params[:gj]}'" if params[:gj].size > 0
    conditions << "inputer='#{params[:user]}'" if params[:user].size > 0
    conditions << "inputtime>='#{params[:inputtime]}'" if params[:inputtime].size > 0
    conditions << "inputtime<='#{params[:inputtime2]}'" if params[:inputtime2].size > 0
    if params[:jg].size > 0
      jg = params[:jg].split("-")
      conditions << "price>=#{jg[0]} and price<=#{jg[1]}" 
    end
    conditions << "xq like '%#{params[:xq]}%'" if params[:xq].size > 0
    
    if params[:mj].size > 0
      mj = params[:mj].split("-")
      conditions << "mj>=#{mj[0]} and mj<=#{mj[1]}" 
    end
    conditions << "szc>=#{params[:szc1]}" if params[:szc1].size > 0
    conditions << "szc<=#{params[:szc2]}" if params[:szc2].size > 0
    
    ids = session[:user].department.quyus.collect{ |q|
      q.id
    }
    ids << -1
    
    ids = ids.join(',')
    
    conditions << "quyu_id in (#{ids})"
    
    @houses  = House.find(:all, :conditions=>conditions.join(' and '), :order=>"id desc")
  end 
  
  def changedizhi
    @quyu = Quyu.find(:first, :conditions=>"id = '#{params[:name]}'")
    render :layout=>false
  end
  
  def changexq
    @quyu = Quyu.find(params[:name])
    render :layout=>false
  end
  
  def secrettag
    house = House.find(params[:id])
    house.secrettag = 1
    house.save
    
    flash[:notice] = "操作成功"
    redirect_to :action=>"sell_list", :page=>house.page
  end
end
