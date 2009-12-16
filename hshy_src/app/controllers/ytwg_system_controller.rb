class YtwgSystemController < ApplicationController
  def index
    @config = YtwgSystem.find(:all, :limit=>1)[0]
    @config = YtwgSystem.new if !@config
  end
  
  def update
    @config = YtwgSystem.find(:all, :limit=>1)[0]
    if @config.update_attributes(params[:config])
      flash[:notice] = '�޸�ϵͳ���óɹ�'
      redirect_to :action => 'index'
    else
      render :action => 'index'
    end
  end
  
  def delete
    @config = YtwgSystem.find(:all, :limit=>1)[0]
    @config.logo = nil
    @config.save
    render :action => 'index'
  end
  
  def reboot
    $REBOOT = true
    render :text=>"�ɹ���������20������"
  end
  
  def clear_session
    count = 0
    yesterday = Time.new.yesterday
    dir = Dir.open("tmp/sessions")
    begin
      dir.each { |path|
        next if ['.', '..'].include?(path)
        path = "tmp/sessions/" + path
        if File.ctime(path) < yesterday
          count += 1
          File.delete(path)
        end
      }
    ensure
      dir.close
    end

    flash[:notice] = "ɾ���ļ�#{count}��"
    render :action => 'index'
  end
end
