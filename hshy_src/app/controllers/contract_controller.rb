class ContractController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @department_id = params[:department] || Department.find(:first).id
    @contracttype = params[:contracttype] || DicContract.find(:first).id
    if params[:code] && params[:code].size > 0
      @contracts = Contract.paginate :page=>1, :per_page=>100, :conditions=>"code='#{params[:code]}'"
      @count = Contract.count "code='#{params[:code]}'"
    else
      @status = params[:status] || 1
      @contracts = Contract.paginate :page=>params[:page], :per_page => 20, :order=>"department_id, id desc",
        :conditions=>"status = #{@status}  and department_id = #{@department_id} and contract_type = #{@contracttype}"
      @count = Contract.count "status = #{@status}  and department_id = #{@department_id}"
    end
  end

  def show
    @contract = Contract.find(params[:id])
  end

  def new
    @contract = Contract.new
    params[:page] = params[:page] || 1
    @contract.needcheck = 1
  end

  def create
    @contract = Contract.new(params[:contract])
    @contract.status = 0
    @contract.publish_time = Time.new
    @contract.publisher = session[:user].truename
    if @contract.save
      flash[:notice] = '录入合同成功.'
      redirect_to :action => 'list', :page=>params[:page], :status=>0, :department=>@contract.department_id
    else
      render :action => 'new'
    end
  end

  def edit
    @contract = Contract.find(params[:id])
  end

  def update
    @contract = Contract.find(params[:id])
    if @contract.update_attributes(params[:contract])
      flash[:notice] = '修改成功'
      redirect_to :action => 'list', :status=>@contract.status, :page=>@contract.page, :department=>@contract.department_id
    else
      render :action => 'edit'
    end
  end

  def destroy
    Contract.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
  
  def check
    @contract = Contract.find(params[:id])
    @contract.needcheck = 0
    @contract.status = 1
    @contract.department_id  = session[:user].department.id
    @contract.user_id = session[:user].id
    @contract.use_time = Time.new
    @contract.save
    flash[:notice] = "领用成功"
    @contract.save
    #flash[:notice] = "确认成功"
    redirect_to :action=>"list", :status=>0
  end
  
  def get
    @contract = Contract.find(params[:id])
    @contract.status = 1
    @contract.department_id  = session[:user].department.id
    @contract.user_id = session[:user].id
    @contract.use_time = Time.new
    @contract.save
    flash[:notice] = "领用成功"
    redirect_to :action=>"list"
  end
  
  def back
    @contract = Contract.find(params[:id])
    @contract.status = 0
    @contract.save
    flash[:notice] = "退回成功"
    redirect_to :action=>"list"
  end
  
  def transfer
    @contract = Contract.find(params[:id])
    user = YtwgUser.find(params[:contract][:user_id])
    @contract.user_id = user.id
    @contract.department_id = user.department.id
    
    @contract.save
    
    flash[:notice] = "转移成功"
    write_log("#{session[:user].truename}转移了id为#{@contract.id}的合同给#{YtwgUser.find(params[:contract][:user_id]).truename}")
    redirect_to :action=>"list"
  end
end
