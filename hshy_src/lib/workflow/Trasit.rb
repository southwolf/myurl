class Trasit
	attr_accessor :condition, :name, :from, :to
	
	#新建流转类，from,to均为State类对象
	def initialize(from, to)
		@from = from
		@to = to
	end
end