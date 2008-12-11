# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{rubyvor}
  s.version = "0.0.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Brendan Ribera"]
  s.date = %q{2008-12-11}
  s.description = %q{RubyVor provides efficient computation of Voronoi diagrams and Delaunay triangulation for a set of Ruby points. It is intended to function as a complemenet to GeoRuby. These structures can be used to compute a nearest-neighbor graph for a set of points. This graph can in turn be used for proximity-based clustering of the input points.}
  s.email = ["brendan.ribera+rubyvor@gmail.com"]
  s.extensions = ["ext/extconf.rb"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.txt"]
  s.files = ["History.txt", "Manifest.txt", "README.txt", "Rakefile", "ext/Doc", "ext/edgelist.c", "ext/extconf.rb", "ext/geometry.c", "ext/heap.c", "ext/memory.c", "ext/output.c", "ext/rb_cComputation.c", "ext/rb_cPoint.c", "ext/rb_cPriorityQueue.c", "ext/ruby_vor.c", "ext/ruby_vor.h", "ext/vdefs.h", "ext/voronoi.c", "lib/ruby_vor.rb", "lib/ruby_vor/computation.rb", "lib/ruby_vor/point.rb", "lib/ruby_vor/priority_queue.rb", "lib/ruby_vor/version.rb", "rubyvor.gemspec", "test/test_computation.rb", "test/test_priority_queue.rb", "test/test_voronoi_interface.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/bribera/rubyvor}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib", "ext"]
  s.rubyforge_project = %q{rubyvor}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{RubyVor provides efficient computation of Voronoi diagrams and Delaunay triangulation for a set of Ruby points}
  s.test_files = ["test/test_voronoi_interface.rb", "test/test_computation.rb", "test/test_priority_queue.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<hoe>, [">= 1.8.2"])
    else
      s.add_dependency(%q<hoe>, [">= 1.8.2"])
    end
  else
    s.add_dependency(%q<hoe>, [">= 1.8.2"])
  end
end
