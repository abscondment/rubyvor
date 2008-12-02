# -*- ruby -*-


require 'rubygems'
require 'hoe'
require './lib/rubyvor.rb'

Hoe.new('rubyvor', RubyVor::VERSION) do |p|
  #p.rubyforge_name = 'rubyvor'
  p.developer('Brendan Ribera', 'brendan.ribera@gmail.com')
end

desc "Copying Phil"
task :github do
  system "git ls-files > Manifest.txt"
  system "rake debug_gem | egrep -v \"^\\(in\" > rubyvor.gemspec"
end

task :gem => :github

=begin
task :default => :test

desc "Run the tests"
Rake::TestTask.new do |t|
  t.test_files = FileList['test/test*.rb']
  t.verbose = true
end
task :test => :compile_clean

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
    pid = fork { exec "#{MAKECMD} #{MAKEOPTS} #{target}" }
    Process.waitpid pid
  end
  $?.exitstatus
end

# Let make handle dependencies between c/o/so - we'll just run it.
file 'ext/voronoi_interface.so' => 'ext/Makefile' do
  m = make
  fail "Make failed (status #{m})" unless m == 0
end

desc "Compile the shared object"
task :compile => 'ext/voronoi_interface.so'

desc "Regenerate Makefile and perform a clean compile of shared object"
task :compile_clean do
  Dir.chdir('ext/') do
    ruby 'extconf.rb' unless File.exists?('Makefile')
    `make clean`
    `rm -f Makefile`
  end

  Rake::Task[:compile].invoke
end

spec = Gem::Specification::new do |s|
  s.platform = Gem::Platform::RUBY

  s.name = 'RubyVor'
  s.version = "0.1"
  # s.date
  s.summary = "Efficient Voronoi diagrams and Delaunay trianglation for Ruby"
  s.description = <<EOF
Efficient Voronoi diagrams and Delaunay trianglation for Ruby
EOF
  s.author = 'Brendan Ribera'
  s.email = 'brendan.ribera@gmail.com'
  s.homepage = "http://github.com/bribera/rubyvor"
  s.rubyforge_project = nil
  
  s.requirements << 'none'
  s.require_path = 'lib'
  
  s.files = FileList["lib/**/*.rb", "test/**/*.rb", "ext/*.rb", "ext/*.c", "ext/*.h", "README","MIT-LICENSE","Rakefile"]
  s.test_files = FileList['test/test*.rb']

  s.has_rdoc = true
  s.extra_rdoc_files = ["README"]
  s.rdoc_options.concat ['--main',  'README']

  s.extensions = ['ext/extconf.rb']
end

desc "Package the library as a gem"
Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end
=end
