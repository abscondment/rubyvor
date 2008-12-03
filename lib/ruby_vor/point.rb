module RubyVor
  class Point
    attr_accessor :x, :y
    def initialize(x=0.0,y=0.0)
      @x = x
      @y = y
    end

    class << self
      def test_points
        if @rarray.nil?
          @rarray = []
          parray = %w{ 0.0 0.0
                       0.0 0.5
                       0.5 0.0
                       3 3
                       0.5 0.5
                       5.0 5.0
                       5.0 5.5
                       5.5 5.0
                       5.5 5.5 }
          for x in 0..(parray.length/2 - 1)
            @rarray << new(parray[x * 2].to_f, parray[x * 2 + 1].to_f)
          end
        end
        @rarray
      end

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
