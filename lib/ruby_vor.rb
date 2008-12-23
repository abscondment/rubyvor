$:.unshift File.dirname(__FILE__)
$:.unshift File.join(File.dirname(__FILE__), '..', 'ext')

require 'ruby_vor/version'
require 'ruby_vor/point'
require 'ruby_vor/priority_queue'
require 'ruby_vor/computation'
require 'ruby_vor/geo_ruby_extensions'
require 'ruby_vor/visualizer'

# Require ruby_vor.so last to clobber old from_points
require 'ruby_vor_c.so'

# DOC HERE
module RubyVor
end
