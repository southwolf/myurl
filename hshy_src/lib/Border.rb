class Border
    attr_accessor :LineStyle, :LineWidth, :LineColor, :bDisplay
    def initialize
        @LineStyle = 0
        @LineWidth = 1
        @LineColor = 0
        @bDisplay  = true
    end
    
    def ==(other)
        members = other.instance_variables
        for member in members
            if self.instance_variable_get(member) != other.instance_variable_get(member)
                return false
            end
        end
        true
    end
end