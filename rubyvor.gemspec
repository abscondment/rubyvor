# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{rubyvor}
  s.version = "0.1.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Brendan Ribera"]
  s.date = %q{2011-01-27}
  s.description = %q{RubyVor provides efficient computation of Voronoi diagrams and Delaunay triangulation for a set of Ruby points. It is intended to function as a complemenet to GeoRuby. These structures can be used to compute a nearest-neighbor graph for a set of points. This graph can in turn be used for proximity-based clustering of the input points.}
  s.email = ["brendan.ribera+rubyvor@gmail.com"]
  s.extensions = ["ext/extconf.rb"]
  s.extra_rdoc_files = ["Manifest.txt"]
  s.files = ["History.rdoc", "Manifest.txt", "README.rdoc", "Rakefile", "ext/Doc", "ext/edgelist.c", "ext/extconf.rb", "ext/geometry.c", "ext/heap.c", "ext/memory.c", "ext/output.c", "ext/rb_cComputation.c", "ext/rb_cPoint.c", "ext/rb_cPriorityQueue.c", "ext/ruby_vor_c.c", "ext/ruby_vor_c.h", "ext/vdefs.h", "ext/voronoi.c", "lib/rubyvor.rb", "lib/ruby_vor.rb", "lib/ruby_vor/computation.rb", "lib/ruby_vor/geo_ruby_extensions.rb", "lib/ruby_vor/point.rb", "lib/ruby_vor/priority_queue.rb", "lib/ruby_vor/version.rb", "lib/ruby_vor/visualizer.rb", "rubyvor.gemspec", "test/test_computation.rb", "test/test_point.rb", "test/test_priority_queue.rb", "test/test_voronoi_interface.rb"]
  s.homepage = %q{https://github.com/abscondment/rubyvor}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{rubyvor}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Efficient Voronoi diagrams and Delaunay trianglation for Ruby}
  s.test_files = ["test/test_computation.rb", "test/test_point.rb", "test/test_priority_queue.rb", "test/test_voronoi_interface.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<libxml-ruby>, [">= 0.9.9"])
      s.add_runtime_dependency(%q<GeoRuby>, [">= 1.3.0"])
      s.add_development_dependency(%q<minitest>, [">= 1.6.0"])
      s.add_development_dependency(%q<hoe>, [">= 2.8.0"])
    else
      s.add_dependency(%q<libxml-ruby>, [">= 0.9.9"])
      s.add_dependency(%q<GeoRuby>, [">= 1.3.0"])
      s.add_dependency(%q<minitest>, [">= 1.6.0"])
      s.add_dependency(%q<hoe>, [">= 2.8.0"])
    end
  else
    s.add_dependency(%q<libxml-ruby>, [">= 0.9.9"])
    s.add_dependency(%q<GeoRuby>, [">= 1.3.0"])
    s.add_dependency(%q<minitest>, [">= 1.6.0"])
    s.add_dependency(%q<hoe>, [">= 2.8.0"])
  end
end
