module RubyVor
  class Point
    attr_reader :x, :y
    def initialize(x=0.0,y=0.0)
      @x = x; @y = y
    end
    
    def ==(p)
      @x == p.x && @y == p.y
    end
    alias :eql? :==
    def hash
      [x.to_f, y.to_f].hash
    end

  end
end
