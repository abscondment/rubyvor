module RubyVor
  
  # Voronoi Digram and Delaunay Triangulation namespace.
  module VDDT
    
    # Represents a computation from a set of 2-dimensional points
    class Computation
      attr_reader :points, :voronoi_diagram_raw, :delaunay_triangulation_raw
      
      def initialize(points=[], vd_raw=[], dt_raw=[])
        @voronoi_diagram_raw = vd_raw
        @delaunay_triangulation_raw   = dt_raw
      end

      class << self

        # Compute the voronoi diagram and delaunay triangulation from a set of points.
        #
        # This implementation uses Steven Fortune's sweepline algorithm, which runs in O(n log n) time and O(n) space.
        # It is limited to 2-dimensional space, therefore it expects to receive an array of objects that respond to 'x' and 'y' methods.
        def from_points(p)
          # Stub; implemented as C function in voronoi_interface.so
        end        
      end
      
    end
  end
end
