# -*- ruby -*-

require 'rubygems'
require 'hoe'
require './lib/ruby_vor/version.rb'

EXT = "ext/voronoi_interface.#{Hoe::DLEXT}"

Hoe.new('rubyvor', RubyVor::VERSION) do |p|
  p.developer('Brendan Ribera', 'brendan.ribera+rubyvor@gmail.com')  
  p.url = 'http://github.com/bribera/rubyvor'

  # C extension goodness
  p.spec_extras[:extensions] = "ext/extconf.rb"
  p.clean_globs << EXT << 'ext/*.o' << 'ext/Makefile'
end

desc "Compile extensions"
task :compile => EXT
task :test => :compile

file EXT => ['ext/extconf.rb', 'ext/ruby_vor.c'] do
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
