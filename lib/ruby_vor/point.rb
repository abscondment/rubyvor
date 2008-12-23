module RubyVor
  class Point
    attr_reader :x, :y
    def initialize(x=0.0,y=0.0)
      raise TypeError, 'Must be able to convert point values into floats' unless x.respond_to?(:to_f) && y.respond_to?(:to_f)
      @x = x.to_f
      @y = y.to_f
    end

    def <=>(p)
      (@x != p.x) ? @x <=> p.x : @y <=> p.y
    end

    def <(p)
      (self <=> p) == -1
    end

    def >(p)
      (self <=> p) == 1
    end
    
    def ==(p)
      @x == p.x && @y == p.y
    end
    alias :eql? :==

    def to_s
      "(#{@x},#{@y})"
    end    

  end
end
