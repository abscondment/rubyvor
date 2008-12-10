$:.unshift File.dirname(__FILE__)
$:.unshift File.join(File.dirname(__FILE__), '..', 'ext')

require 'ruby_vor/version'
require 'ruby_vor/point'
require 'ruby_vor/priority_queue'
require 'ruby_vor/computation'

# Require voronoi_interface.so last to clobber old from_points
require 'voronoi_interface.so'

# DOC HERE
module RubyVor
end
