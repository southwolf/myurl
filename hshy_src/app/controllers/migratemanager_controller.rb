class MigratemanagerController < ApplicationController
  def index
    @migrations = Array.new
    dir = Dir.open('.\db\migrate')
    begin
      dir.each { |item|
        @migrations<<item if item!='.' && item !='..'
      }
    ensure
      dir.close
    end
  end
  
  #�½�migrate
  def create
    `ruby script/generate migration #{params[:name]}`
    flash[:notice] = "�½�#{params[:name]}�ļ��ɹ�"
    redirect_to :action=>"index"
  end
  
  #�༭migrate
  def edit
    file = File.open(".\\db\\migrate\\#{params[:name]}", "r")
    @data = file.read
    file.close
  end
  
  def delete
    File.delete(".\\db\\migrate\\#{params[:name]}")
    flash[:notice] = "ɾ��#{params[:name]}�ļ��ɹ�"
    redirect_to :action=>"index"
  end
  
  def update
    file = File.open(".\\db\\migrate\\#{params[:name]}", "w")
    file.write params[:data]
    file.close
    flash[:notice] = "�޸�#{params[:name]}�ļ��ɹ�"
    redirect_to :action=>"index"
  end
  
  def execute
    `rake db:migrate VERSION=#{params[:name].to_i}`
    flash[:notice] = "ִ�����"
    redirect_to :action=>"index"
  end
end
