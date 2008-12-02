= rubyvor

Efficient Voronoi diagrams and Delaunay trianglation for Ruby

== Description

RubyVor provides efficient computation of Voronoi diagrams and
Delaunay triangulation for a set of Ruby points. It is intended to
function as a complemenet to GeoRuby.

== Usage:

  require 'rubyvor'
  vddt = RubyVor::VDDT::Decomposition.from_points(georuby_points)

== LICENSE:

Original public-domain C code (by Steven Fortune; http://ect.bell-labs.com/who/sjf/) and
memory-management fixes for said C code (by Derek Bradley; http://www.derekbradley.ca)
used and released under the MIT-LICENSE with permission.


(The MIT License)


Copyright (c) 2008 Brendan Ribera <brendan.ribera+rubyvor@gmail.com>


Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
