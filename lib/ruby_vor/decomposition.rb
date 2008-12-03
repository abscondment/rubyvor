module RubyVor
  module VDDT
    class Decomposition
      attr_reader :voronoi_diagram_raw, :triangulation_raw
      def initialize(vd_raw=[], dt_raw=[])
        @voronoi_diagram_raw = vd_raw
        @triangulation_raw   = dt_raw
      end
      
      private

      def voronoi_diagram_raw=(v)
        @voronoi_diagram_raw = v
      end

      def triangulation_raw=(v)
        @triangulation_raw = v
      end
      
    end
  end
end
