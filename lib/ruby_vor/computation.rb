module RubyVor
  module VDDT
    class Computation
      attr_reader :points, :voronoi_diagram_raw, :delaunay_triangulation_raw

      DIST_PROC = lambda{|a,b| a.distance_from(b)}
      
      # Create a computation from an existing set of raw data.
      def initialize
        @points = []
        @unique_points = []
        @point_map = {}
        @voronoi_diagram_raw = []
        @delaunay_triangulation_raw = []
        @nn_graph = nil
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
        
        nn_graph.each_with_index do |neighbors,v|
          graph[v] = neighbors.select do |neighbor|
            dist_proc[points[v], points[neighbor]] < max_distance
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

      # Computes the minimum spanning tree for given points, using the Delaunay triangulation as a seed.
      #
      # For points on a Euclidean plane, the MST is always comprised of a subset of the edges in a Delaunay triangulation. This makes computation of the tree very efficient: simply compute the Delaunay triangulation, and then run Prim's algorithm on the resulting edges.
      def minimum_spanning_tree(dist_proc=DIST_PROC)
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

        nodes.inject({}) do |h,item|
          unless item.data[1].nil?
            key = (item.data[0] < item.data[1].data[0]) ? [item.data[0], item.data[1].data[0]] : [item.data[1].data[0], item.data[0]]
            h[key] ||= item.priority
          end
          h
        end        
      end

      def cluster_by_size(sizes=[], dist_proc=DIST_PROC)
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
          
          visited  = [nil] * points.length
        
          for edge in mst
            i, j = edge.first
            
            next if !visited[i].nil? && visited[i] == visited[j]
            
            if visited[i] && visited[j]
              visited[i].concat(visited[j])
              visited[i].uniq!
              visited[j].each{|v| visited[v] = visited[i]}
              visited[j] = visited[i]
            else
              cluster = visited[i] || visited[j] || []  
              cluster.push(i) unless visited[i]
              cluster.push(j) unless visited[j]
              visited[i] = visited[j] = cluster
            end
          end

        
          visited.each_with_index do |visits, v|
            if visits.nil?
              visited[v] = [v]
            end
          end
          
          sized_clusters[current_size + 1] = visited.uniq
          
          last_size = current_size
        end
        
        sized_clusters
      end


    end
  end
end
