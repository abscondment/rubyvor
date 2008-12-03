$:.unshift File.dirname(__FILE__)
$:.unshift File.join(File.dirname(__FILE__), '..', 'ext')
require 'voronoi_interface.so'
require 'ruby_vor/version'
require 'ruby_vor/point'

module RubyVor
  def self.test_c
    VDDT::Decomposition.from_points(Point.test_points)
  end
  def self.test_l
    VDDT::Decomposition.from_points(Point.test_large)
  end
  
end
