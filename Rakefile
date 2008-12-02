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


=begin
spec = Gem::Specification::new do |s|
  s.platform = Gem::Platform::RUBY

  s.name = 'GeoRuby'
  s.version = "1.3.3"
  s.summary = "Ruby data holder for OGC Simple Features"
  s.description = <<EOF
GeoRuby is intended as a holder for data returned from PostGIS and MySQL Spatial queries. The data model roughly follows the OGC "Simple Features for SQL" specification (see www.opengis.org/docs/99-049.pdf), although without any kind of advanced functionalities (such as geometric operators or reprojections)
EOF
  s.author = 'Guilhem Vellut'
  s.email = 'guilhem.vellut@gmail.com'
  s.homepage = "http://thepochisuperstarmegashow.com/projects/"
  
  s.requirements << 'none'
  s.require_path = 'lib'
  s.files = FileList["lib/**/*.rb", "test/**/*.rb", "README","MIT-LICENSE","rakefile.rb","test/data/*.shp","test/data/*.dbf","test/data/*.shx","tools/**/*.yml","tools/**/*.rb","tools/lib/**/*"]
  s.test_files = FileList['test/test*.rb']

  s.has_rdoc = true
  s.extra_rdoc_files = ["README"]
  s.rdoc_options.concat ['--main',  'README']
end

desc "Package the library as a gem"
Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end












ooooooooooooooooooooooor


spec = Gem::Specification.new do |s|
  s.name = %q{teius}
  # Note: search both lib, ext for teius.so
  s.version = "0.11"
  s.date = %q{2006-07-27}
  s.summary = %q{Light-weight Ruby API to LibXML.}
  s.email = %q{joshmh@gmail.com}
  s.homepage = %q{http://teius.rubyforge.org}
  s.rubyforge_project = %q{teius}
  s.description = %q{Teius is a very lightweight Ruby API around the LibXML C library. The idea is to use a syntax reminiscent of Ruby On Rails' find method to quickly process information from an XML document.}
  s.require_paths = [ 'lib' ]
  s.autorequire = %q{teius}
  s.has_rdoc = false
  s.authors = ["Joshua Harvey"]
  s.files = FileList[ '{test,xml,doc}/**/*', 'ext/*.rb', 'ext/*.c', 'lib/*.rb',
    'Rakefile' ].to_a
  s.test_file = 'test/teius_test.rb'
  s.platform = Gem::Platform::RUBY
  s.extensions = [ 'ext/extconf.rb' ]
#  s.rdoc_options = ["--main", "README"]
#  s.extra_rdoc_files = ["README"]
end
Rake::GemPackageTask.new(spec) do |pkg|
pkg.need_zip = false
pkg.need_tar = true
end

Rake::GemPackageTask.new(win_spec) do |pkg|
pkg.need_zip = true
pkg.need_tar = false
end









=end
