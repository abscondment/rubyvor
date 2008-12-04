module RubyVor
  # Basic 2-d point
  class Point
    attr_accessor :x, :y
    def initialize(x=0.0,y=0.0)
      @x = x; @y = y
    end
  end
end
