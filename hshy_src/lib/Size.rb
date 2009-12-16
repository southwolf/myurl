class CSize
    attr_accessor :x, :y
    def initialize(cx,cy)
        @x = cx
        @y = cy
    end
    
    def cx=(other)
        @x = other
    end
    
    def cy=(other)
        @y = other
    end
    
    def cx
        @x
    end
    
    def cy
        @y
    end
end

class CRect
    attr_reader :left, :right, :top, :bottom
    attr_writer :left, :right, :top, :bottom
    def initialize(*args)
        @left = 0
        @right = 0
        @top = 0
        @bottom = 0
        if args.length == 4
            @left = args[0]
            @top = args[1]
            @right = args[2]
            @bottom = args[3]
        elsif args.length == 1
            @left = args[0].left
            @top = args[0].top
            @right = args[0].right
            @bottom = args[0].bottom
        end
    end
    
    def Width
        @right - @left
    end
    
    def Height
        @bottom - @top
    end
end

class CPoint
    attr_reader :x, :y
    attr_writer :x, :y
    def initialize(x, y)
        @x = x
        @y = y
    end
end
