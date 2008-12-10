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

      # Uses the nearest-neighbors information encapsulated by the Delaunay triangulation as a seed for clustering:
      # We take the edges (there are O(n) of them, because  defined by the triangulation and delete any edge above a certain distance.
      #
      # This method allows the caller to pass in a lambda for customizing distance calculations. For instance, to use a GeoRuby::SimpleFeatures::Point, one would:
      #  > cluster_by_distance(50 lambda{|a,b| a.spherical_distance(b, 3958.754)}) # this rejects edges greater than 50 miles, using spherical distance as a measure
      def cluster_by_distance(max_distance, dist_proc=lambda{|a,b| a.distance_from(b)})

        clusters = []
        nodes    = (0..points.length-1).to_a
        visited  = []
        
        v = 0
        graph = nn_graph.map do |neighbors|
          neighbors = neighbors.reject do |neighbor|
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

      # Computes the minimum spanning tree for given points, using the Delaunay triangulation as a seed.
      #
      # For points on a Euclidean plane, the MST is always comprised of a subset of the edges in a Delaunay triangulation. This makes computation of the tree very efficient: simply compute the Delaunay triangulation, and then run Prim's algorithm on the resulting edges.
      def minimum_spanning_tree(dist_proc=lambda{|a,b| a.distance_from(b)})
        nodes = []
        q = RubyVor::PriorityQueue.new(lambda{|a,b| a[:min_distance] < b[:min_distance]})
        (0..points.length-1).to_a.map do |n|
          q.push({
            :node => n,
            :min_distance => (n == 0) ? 0.0 : Float::MAX,
            :parent => nil,
            :adjacency_list => nn_graph[n].clone,
            :min_adjacency_list => [],
            :in_q => true
          })
        end

        
        q.data.each do |n|
          n[:adjacency_list].map!{|v| q.data[v]}
          nodes.push(n)
        end

        while latest_addition = q.pop
          
          latest_addition[:in_q] = false

          if latest_addition[:parent]
            latest_addition[:parent][:min_adjacency_list].push(latest_addition)
            latest_addition[:min_adjacency_list].push(latest_addition[:parent])
          end

          latest_addition[:adjacency_list].each do |adjacent|
            
            if adjacent[:in_q]

              adjacent_distance = dist_proc[ points[latest_addition[:node]], points[adjacent[:node]] ]
              
              if adjacent_distance < adjacent[:min_distance]
                adjacent[:parent] = latest_addition
                adjacent[:min_distance] = adjacent_distance
                
              end
            end
          end
          
          q.reorder_queue()
        end

        nodes.map! do |n|
          n[:min_adjacency_list].map!{|v| v[:node]}
        end
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

      protected

      def weighted_edges(dist_proc)
        v = 0
        edges = nn_graph.inject({}) do |eh, neighbors|
          neighbors.each do |neighbor|
            k = [v,neighbor].sort
            eh[k] = dist_proc.call(points[v],points[neighbor]) unless eh.has_key?(k)
          end
          v += 1
          eh
        end.to_a
      end

    end
  end
end
