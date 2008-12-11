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
        q = RubyVor::PriorityQueue.new
        (0..points.length-1).to_a.map do |n|
          q.push([
                  n,                 #               :node == 0
                  nil,               #             :parent == 1
                  nn_graph[n].clone, #     :adjacency_list == 2
                  [],                # :min_adjacency_list == 3
                  true               #               :in_q == 4
                 ],
                 # Set min_distance of first node to 0, all others (effectively) to Infinity.
                 (n == 0) ? 0.0 : Float::MAX)
        end

        # Adjacency list accces
        nodes = q.data.clone

        # We have now prepped to run through Prim's algorithm.
        while latest_addition = q.pop
          # check :in_q
          latest_addition.data[4] = false

          # check :parent
          if latest_addition.data[1]
            # push this node into :adjacency_list of :parent
            latest_addition.data[1].data[3].push(latest_addition)
            # push :parent into :adjacency_list of this node
            latest_addition.data[3].push(latest_addition.data[1])
          end

          latest_addition.data[2].each do |adjacent|
            # grab indexed node
            adjacent = nodes[adjacent]

            # check :in_q -- only look at new nodes
            if adjacent.data[4]
              # compare points by :node -- adjacent against current
              adjacent_distance = dist_proc[ points[latest_addition.data[0]], points[adjacent.data[0]] ]

              # if the new distance is better than our current priorty, exchange them
              if adjacent_distance < adjacent.priority
                # set new :parent
                adjacent.data[1] = latest_addition
                # update priority
                adjacent.priority = adjacent_distance
                # percolate up into correct position
                q.percolate_up(adjacent.index)
              end
            end
          end

        end


        nodes.map! do |n|
          n.data[3].inject({}) do |h,v|
            h[v.data[0]] = v.priority
            h
          end
        end
      end

      def cluster_by_size(sizes=[])
        # TODO
        # *    (DONE) Create a minimum_spanning_tree routine to:
        #   1. (DONE) compute weights (should be done for us in C?)
        #   2. (DONE) Use Prim's algorithm for computation
        #
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
