module RubyVor
  class Point
    attr_accessor :x, :y
    def initialize(x=0.0,y=0.0)
      @x = x
      @y = y
    end

    class << self
      def test_large
        a = []
        1000000.times {
          a << new(100000.0 * rand, 100000.0 * rand)
        }
        a
      end
    end
  end
end
