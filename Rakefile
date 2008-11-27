require 'rubygems'
require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/gempackagetask'

task :default => :test

desc "Run the tests"
Rake::TestTask.new do |t|
  t.test_files = FileList['test/test*.rb']
  t.verbose = true
end
task :test => :compile

desc "Generate the documentation"
Rake::RDocTask::new do |rdoc|
  rdoc.rdoc_dir = 'rubyvor-doc/'
  rdoc.title    = "RubyVor Documentation"
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('MIT-LICENSE')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

# Compile the extension
MAKECMD = ENV['MAKE_CMD'] || 'make'
MAKEOPTS = ENV['MAKE_OPTS'] || ''

file 'ext/Makefile' => 'ext/extconf.rb' do
  Dir.chdir('ext/') do
    ruby 'extconf.rb'
  end
end

def make(target = '')
  Dir.chdir('ext/') do
    pid = fork { exec "#{MAKECMD} #{ MAKEOPTS} #{ target}" }
    Process.waitpid pid
  end
  $?.exitstatus
end

# Let make handle dependencies between c/o/so - we'll just run it.
file 'ext/voronoi_interface.so' => 'ext/Makefile' do
  m = make
  fail "Make failed (status #{ m})" unless m == 0
end

desc "Compile the shared object"
task :compile => 'ext/voronoi_interface.so'
