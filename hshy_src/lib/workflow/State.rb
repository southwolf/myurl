##工作流中的状态

require "Trasit"
class State
  attr_accessor :name, :leave, :enter, :right, :trasits, :guest_trasits
  attr_accessor :x1, :x2, :y1, :y2
  def initialize
    #从此状态出发的流转
    @trasits = Array.new
    
    #从其他状态到此状态的流转
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
      start.name = "开始"
      start
    end
  end
end