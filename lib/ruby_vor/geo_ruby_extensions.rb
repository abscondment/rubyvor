if require 'geo_ruby'
  # Let us call uniq on a set of Points or use one as a Hash key.
  module GeoRuby
    module SimpleFeatures
      class Point < Geometry
        def eql?(other)
          self == other
        end
        def hash
          [x,y,z,m].hash
        end
      end
    end
  end
end
