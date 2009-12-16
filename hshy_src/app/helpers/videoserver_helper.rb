module VideoserverHelper
  def parse_ip(text)
    text.each_line{|line|
      line.strip!
      parts = line.split("=")
      return parts[1] if parts[0] == "net.ipaddr"
    }
    return ""
  end
  
  def parse_mac(text)
    text.each_line{|line|
      line.strip!
      parts = line.split("=")
      return parts[1] if parts[0] == "net.ethaddr"
    }
    return ""
  end
  
  def parse_gateway(text)
    text.each_line{|line|
      line.strip!
      parts = line.split("=")
      return parts[1] if parts[0] == "net.gateway"
    }
    return ""
  end
  
  def parse_netmask(text)
    text.each_line{|line|
      line.strip!
      parts = line.split("=")
      return parts[1] if parts[0] == "net.netmask"
    }
    return ""
  end
  
  def parse_server(text)
    text.each_line{|line|
      line.strip!
      parts = line.split("=")
      return parts[1] if parts[0] == "nman.server"
    }
    return ""
  end
end
