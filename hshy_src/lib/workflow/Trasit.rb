class Trasit
	attr_accessor :condition, :name, :from, :to
	
	#�½���ת�࣬from,to��ΪState�����
	def initialize(from, to)
		@from = from
		@to = to
	end
end