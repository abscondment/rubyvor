module RubyVor
  # Basic 2-d point
  class Point
    attr_accessor :x, :y
    def initialize(x=0.0,y=0.0)
      @x = x; @y = y
    end

    def distance_from(p)
      ((self.x - p.x) ** 2 + (self.y - p.y) ** 2) ** 0.5
    end
  end
end
