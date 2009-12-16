class RightController < ApplicationController
  def index
    if params[:commit]
      
      @group = YtwgGroup.find(@params[:id])
      if @group.update_attributes(@params['group'])
        flash[:notice] = "分配权限成功" 
      end
    else
      @group = YtwgGroup.find(params[:group_id]) rescue nil if params[:group_id]
    end
  end
end

