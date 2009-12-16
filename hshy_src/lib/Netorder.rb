module Netorder
  #2字节短整形转换为网络字节流，返回值是字符串
  def short2ns(data)
    [data].pack('n')
  end
  
  #4字节形转换为网络字节流，返回值是字符串
  def int2ns(data)
    [data].pack('N')
  end
  
  def time2ns(time)
    result = ''
    result << short2ns(time.year) << time.month << time.day << time.hour << time.min << time.sec
    result
  end
  
  #从流中读出4字节短整形，做网络字节流转换，data类型为字符串
  def read_int(data)
    t = data[4, data.size-4]
    result = data[0,4].unpack("N")[0] rescue nil
    data.slice!(0..data.size)
    data << t
    result
  end
  
  #从流中读出3字节整形，做网络字节流转换，data类型为字符串
  def read_int3(data)
    t = data[3, data.size-3]
    temp = '' << 0 << data[0, 3]
    result = temp.unpack("N")[0] rescue nil
    data.slice!(0..data.size)
    data << t
    result
  end
  
  #从流中读出2字节短整形，做网络字节流转换，data类型为字符串
  def read_short(data)
    t = data[2, data.size-2]
    result = data[0,2].unpack("n")[0] rescue nil
    data.slice!(0..data.size)
    data << t
    result
  end
  
  #从流中读出1字节数值，data类型为字符串
  def read_byte(data)
    t = data[1, data.size-1]
    result = data[0,1].unpack("c")[0] rescue nil
    data.slice!(0..data.size)
    data << t
    result
  end
  
  #从流中读出字符串，data类型为字符串
  def read_string(data)
    index = data.index(0)
    result = data[0, index]
    t = data[index+1, data.size-index]
    data.slice!(0..data.size)
    data << t
    result
  end
  
  def read_nbyte(data, index)
    result = data[0, index]
    t = data[index, data.size-index]
    data.slice!(0..data.size)
    data << t if t
    result
  end
  
  #从流中读出时间
  def read_time(data)
    year   = read_short(data)
    month  = read_byte(data)
    day    = read_byte(data)
    hour   = read_byte(data)
    min    = read_byte(data)
    sec    = read_byte(data)
    Time.mktime(year, month, day, hour, min, sec)
  end
end

