require "Netorder"
require "deviceinfo"
class NetmanagerController < ApplicationController  
  include Netorder

  def index    
    require 'socket'
    begin
      server = UDPSocket.new
      server.bind("192.168.1.232", 6180)
    rescue 
      render :text=>"����ʧ�ܣ�����6180 UDP�˿��Ƿ�ռ"
      return
    end
    threads = []
    @texts = []
    100.times {
      threads << Thread.new do
        msg, sender = server.recvfrom(2000) 
        command = read_short(msg)
        if command == 0x800A
          len = read_short(msg)
          #read_short(msg)     #����ֵ
          text = msg[2, len]
          @texts << text          
        end
      end
    }
    
    sendtext = ""
    sendtext << short2ns(0x0A)
    sendtext << short2ns(0)
    socket = UDPSocket.new
    socket.connect("255.255.255.255", 6180)
    socket.send(sendtext, 0)
    
    sleep(2)        #��ȴ�ʱ����4��
    server.close
    for thread in threads
      thread.kill
    end
  end
  
  def info
    @text = DeviceInfo.getinfo(params[:ip])
    render :layout=>"notoolbar_app"
  end
  
  def update
    text = ""
    for key in params.keys
      next if ['commit', 'action', 'controller', 'ip'].include?(key)
      text << "#{key}=#{params[key]}\n"
    end

    if DeviceInfo.set_info(params[:ip] ,text) == 0
      flash[:notice] = "�������Գɹ�"
    else
      flash[:notice] = "��������ʧ��"
    end
    
    redirect_to :action=>"info", :ip=>params[:ip]
  end
  
  def sys_command
    DeviceInfo.sys_command(params[:ip], params[:command])
    render :text=>"����ִ�����"
  end
  
  def upgrade
    ret = DeviceInfo.upgrade(params[:ip], params[:image])
    if ret
      render :text=>"������ɣ��ȴ�30�����Ч"
    else
      render :text=>"����ʧ��"
    end
  end
  
  def time_syn
    ret = DeviceInfo.time_syn(params[:ip])
    if ret
      render :text=>"ͬ���豸(#{params[:ip]})ʱ��ɹ�����ʱ��Ч"
    else
      render :text=>"ͬ���豸(#{params[:ip]})ʱ��ʧ��"
    end
  end
end
