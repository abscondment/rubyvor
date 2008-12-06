
module RubyVor
  module VDDT
    class Computation
      attr_reader :points, :voronoi_diagram_raw, :delaunay_triangulation_raw

      # Create a computation from an existing set of raw data.
      def initialize(points=[], vd_raw=[], dt_raw=[])
        @points = points
        @voronoi_diagram_raw = vd_raw
        @delaunay_triangulation_raw = dt_raw
        @nn_graph = nil
      end

      # Use the nearest-neighbors information encapsulated by the Delaunay triangulation as a seed for clustering. We take the edges defined by the triangulation (which is generally sparse) and delete any edge above a certain distance.
      #
      # This method allows the caller to pass in a lambda for customizing distance calculations. For instance, to use a GeoRuby::SimpleFeatures::Point, one would:
      #  > cluster_by_distance(50 lambda{|a,b| a.spherical_distance(b, 3958.754)}) # this rejects edges greater than 50 miles, using spherical distance as a measure
      def cluster_by_distance(max_distance, dist_proc=lambda{|a,b| a.distance_from(b)})

        clusters = []
        nodes    = (0..points.length-1).to_a
        visited  = []
        
        v = 0
        graph = nn_graph.map do |neighbors|
          neighbors.reject! do |neighbor|
            dist_proc[points[v], points[neighbor]] > max_distance
          end
          v += 1
          neighbors
        end

        until nodes.empty?
          v = nodes.pop
          
          next if visited[v]

          cluster = []
          visited[v] = true
          cluster.push(v)

          children = graph[v]
          until children.nil? || children.empty?
            cnode = children.pop
            next if cnode.nil? || visited[cnode]

            visited[cnode] = true
            cluster.push(cnode)
            children.concat(graph[cnode])
          end

          clusters.push(cluster)
        end

        clusters
      end

      def cluster_by_size(sizes=[])
        # TODO
        # * Create a minimum_spanning_tree routine to:
        #   1. compute weights (should be done for us in C?)
        #   2. Use Prim's algorithm for computation
        # * Take MST, and
        #   1. For n in sizes (taken in descending order), delete the n most expensive edges from MST
        #     * use a MaxHeap?
        #   2. Determine remaining connectivity using BFS as above?
        #   3. Some other more efficient connectivity test?
        #   4. Return {n1 => cluster, n2 => cluster} for all n.
      end

    end
  end
end
