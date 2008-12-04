module RubyVor
  module VDDT
    class Computation
      attr_reader :points, :voronoi_diagram_raw, :delaunay_triangulation_raw
      
      def initialize(points=[], vd_raw=[], dt_raw=[])
        @voronoi_diagram_raw = vd_raw
        @delaunay_triangulation_raw   = dt_raw
      end

    end
  end
end
