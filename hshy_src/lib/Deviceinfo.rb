require "socket"
require "Netorder"
include Netorder

class DeviceInfo  
  def DeviceInfo.getinfo(ip)
    begin
      socket = TCPSocket.new(ip, 6180)
    rescue Exception => err
      socket.close
      p err
      return ""
    end  

    sendtext = ""
    command = "device.all\n"    
    sendtext << short2ns(0x02)
    sendtext << short2ns(command.size)
    sendtext << command
    socket.send(sendtext, 0)
    
    @text = ""
    Thread.new(socket) do |socket|
      @text << socket.recv(6000)
      @text << socket.recv(6000)
      @text << socket.recv(6000)
      @text << socket.recv(6000)
    end
    
    #最长只等待5秒钟
    1.upto(15) { |i|
      sleep(1)
      next if !isvalid_packet?(@text.dup)
      text = @text.dup
      packet = get_a_packet(text)
      head = packet[0, 4].dup
      break if read_short(head) == 1
      next if !text || text.size == 0
      packet = get_a_packet(text)
      next if !packet || packet.size==0
      head = packet[0, 4].dup
      break if read_short(head) == 1
    }
    
    while true
      break if !@text || @text.size == 0
      packet = get_a_packet(@text)
      command = read_short(packet)
      if command == 1
        len = read_short(packet)
        ret = read_short(packet)
        if ret == 0
          socket.close
          return packet[0, len-2]
        end
      end
    end

    socket.close
    return ""
  end
  
  def DeviceInfo.set_info(ip, command)
    begin
      socket = TCPSocket.new(ip, 6180)
    rescue Exception => err
      socket.close
      p err
      return -1
    end  
    
    sendtext = ""
    sendtext << short2ns(0x03)
    sendtext << short2ns(command.size)
    sendtext << command
    socket.send(sendtext, 0)   
    
    @ret = -1
    Thread.new() do
        begin      
        while true
          temp = socket.recv(4)
          command = read_short(temp)
          len = read_short(temp)
          text = socket.recv(len)
          if command == 1
            ret_code = read_short(text)
            @ret = ret_code
            break
          end
        end
      rescue Exception => err
         p err
         return -1
      end
    end  
    
    sleep(3)
    socket.close
    return @ret
  end
  
  def DeviceInfo.sys_command(ip, command)
    begin
      socket = TCPSocket.new(ip, 6180)
    rescue Exception => err
      socket.close
      p err
      return false
    end  
    
    sendtext = ""
    sendtext << short2ns(0x04)
    sendtext << short2ns(2)
    sendtext << short2ns(command.to_s.to_i)
    socket.send(sendtext, 0)   
    socket.close
    return true
  end
  
  def DeviceInfo.time_syn(ip)
    begin
      socket = TCPSocket.new(ip, 6180)
    rescue Exception => err
      socket.close
      p err
      return false
    end  
    
    now = Time.new
    sendtext = ""
    sendtext << short2ns(16)
    sendtext << short2ns(7)
    sendtext << short2ns(now.year)
    sendtext << now.month
    sendtext << now.mday
    sendtext << now.hour
    sendtext << now.min
    sendtext << now.sec

    socket.send(sendtext, 0)
    
    return true
  end
  
  def DeviceInfo.upgrade(ip, imageid)
    begin
      socket = TCPSocket.new(ip, 6180)
    rescue Exception => err
      socket.close
      p err
      return false
    end  
    
    image = Fileimage.find(imageid)
    file = File.open(image.path, "rb")
    
    #标识头
    sendtext = ""
    sendtext << short2ns(13)
    sendtext << short2ns(6)
    sendtext << short2ns(1)
    sendtext << int2ns(File.size(image.path))
    socket.send(sendtext, 0)
    
    #标识文件体
    while true
      data = file.read(1024)
      break if !data
      sendtext = ""
      sendtext << short2ns(13)
      sendtext << short2ns(data.size+2)
      sendtext << short2ns(2)
      sendtext << data
      socket.send(sendtext, 0)
    end
    #标识尾
    sendtext = ""
    sendtext << short2ns(13)
    sendtext << short2ns(2)
    sendtext << short2ns(3)
    socket.send(sendtext, 0)
    
    file.close
    return true
  end
  
  def DeviceInfo.isvalid_packet?(text)
    return false if text && text.size < 6
    command = read_short(text)

    len = read_short(text)
    pack_str = text[0, len]
    remain_str = text[len, text.size-len]
    if pack_str.size < len
      return false
    elsif remain_str.size == 0
      return true
    else 
      return DeviceInfo.isvalid_packet?(remain_str)
    end
  end
  
  def DeviceInfo.get_a_packet(text)
    head = text[0, 4].dup
    command = read_short(head)
    len = read_short(head)
    read_nbyte(text, len+4)
  end
end

#p DeviceInfo.getinfo("192.168.1.222")
