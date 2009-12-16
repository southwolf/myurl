require 'rexml/document'
require "State"
require "Trasit"
require "Flow"
require "pp"

include REXML

class Flow 
  attr_accessor :name, :publish_time
  attr_reader :trasits, :states
  def initialize(name, xmlstr, publish_time)
    @publish_time = publish_time
    @name = name
  	
    #�������״̬��������ʼ״̬�ͽ�������ʼ״̬���ڵ�һ��������״̬�������
    @states = Array.new
    @trasits = Array.new
  	
    #����XML�ĵ�
    doc = Document.new(xmlstr)
  	
    #��ʼ����doc�ĵ�
    root = doc.root
  	
    #������ʼ״̬�ڵ�
    root.elements.each("start") {|element|
      start = State.start
      start.name = "��ʼ"
      start.enter = element.attributes["enter"].gbk
      start.leave = element.attributes["leave"].gbk
      start.right = element.attributes["right"].gbk
      start.x1 = element.attributes["x1"].to_i
      start.x2 = element.attributes["x2"].to_i
      start.y1 = element.attributes["y1"].to_i
      start.y2 = element.attributes["y2"].to_i
      @states << start
      break
    }
  	
    #��������״̬�ڵ�
    root.elements.each("state") {|element|
      state = State.new
      state.name = element.attributes["name"].gbk
      state.right = element.attributes["right"].gbk
      state.enter = element.attributes["enter"].gbk
      state.leave = element.attributes["leave"].gbk
      state.x1 = element.attributes["x1"].to_i
      state.x2 = element.attributes["x2"].to_i
      state.y1 = element.attributes["y1"].to_i
      state.y2 = element.attributes["y2"].to_i
      @states << state
    }
  	
    #��������״̬�ڵ�
    root.elements.each("end") {|element|
      end_node = State.new
      end_node.name = "����"
      end_node.right = element.attributes["right"].gbk
      end_node.enter = element.attributes["enter"].gbk
      end_node.x1 = element.attributes["x1"].to_i
      end_node.x2 = element.attributes["x2"].to_i
      end_node.y1 = element.attributes["y1"].to_i
      end_node.y2 = element.attributes["y2"].to_i
      
      @states << end_node
    }
    #����������ת
    root.elements.each("trasit") {|element|
      from_name = element.attributes["from"].gbk
      to_name = element.attributes["to"].gbk
  		
      for state in @states
        if state.name == from_name
          from_node = state
        end
        if state.name == to_name
          to_node = state
        end
      end  		
  		
      trasit = Trasit.new(from_node, to_node)
      trasit.name = element.attributes["name"].gbk
      trasit.condition = element.attributes["condition"].gbk
  		
      from_node.trasits << trasit
      to_node.guest_trasits << trasit
      @trasits << trasit	
    }
  end
  
  def start
    @states[0]
  end
  
  def get_state(name)
    for state in @states
      return state if state.name == name
    end
    nil
  end
  
end