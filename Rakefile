# -*- ruby -*-

require 'rubygems'
require 'hoe'
require './lib/ruby_vor/version.rb'

EXT = "ext/voronoi_interface.#{Config::CONFIG['DLEXT']}"

Hoe.spec 'rubyvor' do
  developer 'Brendan Ribera', 'brendan.ribera+rubyvor@gmail.com'
  
  self.version      = RubyVor::VERSION
  self.url          = 'http://github.com/bribera/rubyvor'
  self.readme_file  = 'README.rdoc'
  self.history_file = 'History.rdoc'
  self.summary      = 'Efficient Voronoi diagrams and Delaunay trianglation for Ruby'
  self.description  = 'RubyVor provides efficient computation of Voronoi diagrams and Delaunay triangulation for a set of Ruby points. It is intended to function as a complemenet to GeoRuby. These structures can be used to compute a nearest-neighbor graph for a set of points. This graph can in turn be used for proximity-based clustering of the input points.'

  extra_dev_deps << ["minitest", ">= 1.6.0"]
  extra_deps << ["libxml-ruby", ">= 0.9.9"]
  extra_deps << ["GeoRuby", ">= 1.3.0"]
  
  # C extension goodness
  self.spec_extras[:extensions] = "ext/extconf.rb"
  self.clean_globs << EXT << 'ext/*.o' << 'ext/Makefile'
end

desc "Compile extensions"
task :compile => EXT
task :test => :compile

file EXT => ['ext/extconf.rb', 'ext/ruby_vor_c.c'] do
  Dir.chdir 'ext' do
    ruby 'extconf.rb'
    sh 'make'
  end    
end

desc "Prepare for github upload"
task :github do
  system "git ls-files | egrep -v \"\\.gitignore\" > Manifest.txt"
  system "rake debug_gem | egrep -v \"^\\(in\" > rubyvor.gemspec"
end

task :gem => :github
