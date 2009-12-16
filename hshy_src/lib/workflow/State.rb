##�������е�״̬

require "Trasit"
class State
  attr_accessor :name, :leave, :enter, :right, :trasits, :guest_trasits
  attr_accessor :x1, :x2, :y1, :y2
  def initialize
    #�Ӵ�״̬��������ת
    @trasits = Array.new
    
    #������״̬����״̬����ת
    @guest_trasits = Array.new
  end
	
  def trasits
    @trasits
  end
	
  def add_trasit(trasit)
    @trasits << trasit
  end
  
  def add_guest_trasit(trasit)
    @guest_trasits << trasit
  end
	
  class << self
    def start
      start = State.new
      start.name = "��ʼ"
      start
    end
  end
end