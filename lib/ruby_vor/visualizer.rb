require 'xml/libxml' unless defined?(LibXML)
module RubyVor
  class Visualizer

    COLORS = %w{black red blue lime gray yellow purple orange pink}

    # Support various versions of LibXML
    include LibXML if defined?(LibXML)
      
    def self.make_svg(computation, opts={})
      @opts = opts = {
        :name            => 'vddt.svg',
        :triangulation   => true,
        :voronoi_diagram => false,
        :mst             => false,
        :cbd             => false,
      }.merge(opts)

      line_colors = COLORS.clone
      
      doc = XML::Document.new()
      
      doc.root = XML::Node.new('svg')
      doc.root['xmlns'] = 'http://www.w3.org/2000/svg'
      doc.root['xml:space'] = 'preserve'

      max_x = 0
      min_x = Float::MAX
      max_y = 0
      min_y = Float::MAX
      pmax_x = 0
      pmin_x = Float::MAX
      pmax_y = 0
      pmin_y = Float::MAX

      computation.points.each do |point|
        max_x = point.x if point.x > max_x
        min_x = point.x if point.x < min_x
        max_y = point.y if point.y > max_y
        min_y = point.y if point.y < min_y
        pmax_x = point.x if point.x > pmax_x
        pmin_x = point.x if point.x < pmin_x
        pmax_y = point.y if point.y > pmax_y
        pmin_y = point.y if point.y < pmin_y
      end

      if opts[:voronoi_diagram]
        computation.voronoi_diagram_raw.each do |item|
          if item.first == :v
            max_x = item[1] if item[1] > max_x
            min_x = item[1] if item[1] < min_x
            max_y = item[2] if item[2] > max_y
            min_y = item[2] if item[2] < min_y
          end
        end
      end
      
      opts[:offset_x] = -1.0 * min_x + 20
      opts[:offset_y] = -1.0 * min_y + 20

      if opts[:triangulation]
        # Draw in the triangulation
        color = line_colors.shift
        computation.delaunay_triangulation_raw.each do |triplet|
          for i in 0..2
            line = line_from_points(computation.points[triplet[i % 2 + 1]], computation.points[triplet[i & 6]])
            line['style'] = "stroke:#{color};stroke-width:1;"            
            doc.root << line
          end
        end
      end

      if opts[:mst]
        color = line_colors.shift
        computation.minimum_spanning_tree.each do |edge, weight|
          line = line_from_points(computation.points[edge[0]], computation.points[edge[1]])
          line['style'] = "stroke:#{color};stroke-width:1;"
          doc.root << line
        end
      end

      if opts[:cbd]
        mst = computation.minimum_spanning_tree
        
        computation.cluster_by_distance(opts[:cbd]).each do |cluster|
          
          color = new_color
          min_dist = Float::MAX
          set_min  = false
          cluster.each do |a|
            cluster.each do |b|
              next if a == b
              k = a < b ? [a,b] : [b,a]
              next unless mst.has_key?(k)

              if mst[k] < min_dist
                min_dist = mst[k]
                set_min = true
              end
            end
          end

          min_dist = 10 unless set_min


          cluster.each do |v|
            node = circle_from_point(computation.points[v])
            node['r'] = (min_dist + 10).to_s
            node['style'] = "fill:#{color};stroke:#{color};"
            node['opacity'] = '0.4'

            doc.root << node
          end

        end
      end

      if opts[:voronoi_diagram]
        voronoi_vertices = []
        draw_lines = []
        draw_points = []
        line_functions = []
        
        xcut = (pmax_x + pmin_x) / 2.0
        ycut = (pmax_y + pmin_y) / 2.0

        color = line_colors.shift

        computation.voronoi_diagram_raw.each do |item|
          case item.first
          when :v
            # Draw a voronoi vertex
            v = RubyVor::Point.new(item[1], item[2])
            voronoi_vertices.push(v)
            node = circle_from_point(v)
            node['fill'] = 'red'
            node['r'] = '2'
            node['stroke'] = 'black'
            node['stroke-width'] = '1'

            draw_points << node
          when :l
            # :l a b c  --> ax + by = c
            a = item[1]
            b = item[2]
            c = item[3]
            line_functions.push({ :y => lambda{|x| (c - a * x) / b},
                                  :x => lambda{|y| (c - b * y) / a} })
          when :e
            if item[2] == -1 || item[3] == -1
              from_vertex = voronoi_vertices[item[2] == -1 ? item[3] : item[2]]
              
              next if from_vertex < RubyVor::Point.new(0,0)              

              if item[2] == -1
                inf_vertex = RubyVor::Point.new(0, line_functions[item[1]][:y][0])
              else
                inf_vertex = RubyVor::Point.new(max_x, line_functions[item[1]][:y][max_x])
              end

              line = line_from_points(from_vertex, inf_vertex)
            else
              line = line_from_points(voronoi_vertices[item[2]], voronoi_vertices[item[3]])
            end

            line['style'] = "stroke:#{color};stroke-width:1;"
            draw_lines << line

          end
        end

        draw_lines.each {|l| doc.root << l}
        draw_points.each {|p| doc.root << p}
      end
      
      # Now draw in nodes
      computation.points.each do |point|
        node = circle_from_point(point)
        node['fill'] = 'lime'

        doc.root << node
      end

      doc.root['width']  = (max_x + opts[:offset_x] + 50).to_s
      doc.root['height'] = (max_y + opts[:offset_y] + 50).to_s
      
      doc.save(opts[:name] || 'vddt.svg')
    end
    
    private
    def self.line_from_points(a, b)
      line = XML::Node.new('line')
      line['x1'] = (a.x + @opts[:offset_x] + 10).to_s
      line['y1'] = (a.y + @opts[:offset_y] + 10).to_s
      line['x2'] = (b.x + @opts[:offset_x] + 10).to_s
      line['y2'] = (b.y + @opts[:offset_y] + 10).to_s
      line
    end
    
    def self.circle_from_point(point)
      node = XML::Node.new('circle')
      node['cx'] = (point.x + @opts[:offset_x] + 10).to_s
      node['cy'] = (point.y + @opts[:offset_y] + 10).to_s
      node['r'] = 5.to_s
      node['stroke'] = 'black'
      node['stroke-width'] = 2.to_s
      node
    end

    def self.new_color
      a = rand(256)
      b = rand(256) | a
      c = rand(256) ^ b
      
      "rgb(#{[a,b,c].sort{|k,l| rand(3)-1}.join(',')})"
    end
  end
end
