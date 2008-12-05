module RubyVor
  module VDDT
    class Computation
      attr_reader :points, :voronoi_diagram_raw, :delaunay_triangulation_raw

      # Create a computation from an existing set of raw data.
      def initialize(points=[], vd_raw=[], dt_raw=[])
        @points = points
        @voronoi_diagram_raw = vd_raw
        @delaunay_triangulation_raw = dt_raw
      end

      # Use the nearest-neighbors information encapsulated by the Delaunay triangulation as a seed for clustering. We take the edges defined by the triangulation (which is generally sparse) and delete any edge above a certain distance.
      #
      # This method allows the caller to pass in a lambda for customizing distance calculations. For instance, to use a GeoRuby::SimpleFeatures::Point, one would:
      #  > cluster_by_distance(50 lambda{|a,b| a.spherical_distance(b, 3958.754)}) # this rejects edges greater than 50 miles, using spherical distance as a measure
      def cluster_by_distance(distance, dist_proc=lambda{|a,b| a.distance_from(b)})
        edges = []
        delaunay_triangulation_raw.each do |triplet|
          k = nil

          k = triplet[0] < triplet[1] ? [triplet[0],triplet[1]] : [triplet[1],triplet[0]]
          #if !edges.has_key?(k)
            d = dist_proc[points[k[0]], points[k[1]]]
            edges.push([k, d]) if d < distance  
          #end

          k = triplet[0] < triplet[2] ? [triplet[0],triplet[2]] : [triplet[2],triplet[0]]
          #if !edges.has_key?(k)
            d = dist_proc[points[k[0]], points[k[1]]]
            edges.push([k, d]) if d < distance  
          #end

          k = triplet[2] < triplet[1] ? [triplet[2],triplet[1]] : [triplet[1],triplet[2]]
          #if !edges.has_key?(k)
            d = dist_proc[points[k[0]], points[k[1]]]
            edges.push([k, d]) if d < distance  
          #end
          
        end
        
        edges.uniq!
        edges
      end

      def cluster_by_size(sizes=[])
      end

    end
  end
end
