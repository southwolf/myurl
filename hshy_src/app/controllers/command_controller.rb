class CommandController < ApplicationController
  def index
    
  end
  
  def command
    `#{params[:command]}`
    flash[:notice] = '����ִ�����'
    redirect_to :action=>'index', :text=>params[:command]
  end
end
