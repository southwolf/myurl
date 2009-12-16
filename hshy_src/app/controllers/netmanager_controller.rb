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
      render :text=>"搜索失败，请检查6180 UDP端口是否被占"
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
          #read_short(msg)     #返回值
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
    
    sleep(2)        #最长等待时间是4秒
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
      flash[:notice] = "设置属性成功"
    else
      flash[:notice] = "设置属性失败"
    end
    
    redirect_to :action=>"info", :ip=>params[:ip]
  end
  
  def sys_command
    DeviceInfo.sys_command(params[:ip], params[:command])
    render :text=>"命令执行完毕"
  end
  
  def upgrade
    ret = DeviceInfo.upgrade(params[:ip], params[:image])
    if ret
      render :text=>"升级完成，等待30秒后生效"
    else
      render :text=>"升级失败"
    end
  end
  
  def time_syn
    ret = DeviceInfo.time_syn(params[:ip])
    if ret
      render :text=>"同步设备(#{params[:ip]})时间成功，即时生效"
    else
      render :text=>"同步设备(#{params[:ip]})时间失败"
    end
  end
end
