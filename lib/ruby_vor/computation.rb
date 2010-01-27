module RubyVor
  module VDDT
    class Computation
      attr_reader :points, :voronoi_diagram_raw, :delaunay_triangulation_raw, :no_neighbor_response

      DIST_PROC = lambda{|a,b| a.distance_from(b)}
      NO_NEIGHBOR_RESPONSES = [:raise, :use_all, :ignore]
      
      # Create a computation from an existing set of raw data.
      def initialize
        @points = []
        
        @voronoi_diagram_raw = []
        @delaunay_triangulation_raw = []
        
        @nn_graph = nil
        @mst = nil

        @no_neighbor_response = :use_all
      end

      # Decided what action to take if we find a point with no neighbors
      # while computing the nn_graph.
      #
      # Choices are:
      #  * :use_all - include all other nodes as potential neighbors. This choice is the default, and can lead to higher big-O lower bounds when clustering.
      #  * :raise - raise an error
      #  * :ignore - leave this node disconnected from the rest of the graph.
      def no_neighbor_response=(v)
        @no_neighbor_response = v if NO_NEIGHBOR_RESPONSES.include?(v)
      end

      # Uses the nearest-neighbors information encapsulated by the Delaunay triangulation as a seed for clustering:
      # We take the edges (there are O(n) of them, because  defined by the triangulation and delete any edge above a certain distance.
      #
      # This method allows the caller to pass in a lambda for customizing distance calculations. For instance, to use a GeoRuby::SimpleFeatures::Point, one would:
      #  > cluster_by_distance(50 lambda{|a,b| a.spherical_distance(b, 3958.754)}) # this rejects edges greater than 50 miles, using spherical distance as a measure
      def cluster_by_distance(max_distance, dist_proc=DIST_PROC)
        clusters = []
        nodes    = (0..points.length-1).to_a
        visited  = [false] * points.length
        graph    = []
        v = 0
        
        nn_graph.each_with_index do |neighbors,nv|
          graph[nv] = neighbors.select do |neighbor|
            dist_proc[points[nv], points[neighbor]] < max_distance
          end
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

      def cluster_by_size(sizes=[], dist_proc=DIST_PROC)
        # * Take MST, and
        #   1. For n in sizes (taken in descending order), delete the n most expensive edges from MST
        #     * TODO: use a MaxHeap?
        #   2. Determine remaining connectivity using BFS as above?
        #   3. Some other more efficient connectivity test?
        #   4. Return {n1 => cluster, n2 => cluster} for all n.
        
        sized_clusters = sizes.inject({}) {|h,s| h[s] = []; h}
        
        
        mst = minimum_spanning_tree(dist_proc).to_a
        mst.sort!{|a,b|a.last <=> b.last}

        sizes = sizes.sort
        last_size = 0

        while current_size = sizes.shift
          current_size -= 1
          
          # Remove edge count delta
          delta = current_size - last_size
          mst.slice!(-delta,delta)

          graph    = (1..points.length).to_a.map{|v| []}
          visited  = [nil] * points.length
          clusters = []

          mst.each do |edge,weight|
            graph[edge[1]].push(edge[0])
            graph[edge[0]].push(edge[1])
          end

          for node in 0..points.length-1
            next if visited[node]

            cluster = [node]
            visited[node] = true

            neighbors = graph[node]
            while v = neighbors.pop
              next if visited[v]

              cluster.push(v)
              visited[v] = true
              neighbors.concat(graph[v])
            end

            clusters.push(cluster)
          end

          sized_clusters[current_size + 1] = clusters
          last_size = current_size
        end
        
        sized_clusters
      end

    end
  end
end
