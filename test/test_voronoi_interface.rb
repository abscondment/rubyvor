require 'rubygems'
require 'minitest/unit'
require File.dirname(__FILE__) + '/../lib/ruby_vor'


class TestVoronoiInterface < MiniTest::Unit::TestCase

  def initialize(*args)
    @points = @trianglulation_raw = @diagram_raw = nil
    super(*args)
  end

  
  MAX_DELTA = 0.000001
  
  def test_diagram_correct
    # Perform the computation.
    comp = RubyVor::VDDT::Computation.from_points(sample_points)

    # Test each raw entry against three basic assertions:
    #  * entry lengths must match
    #  * entry types must match
    #  * entry values must match, with allowance for rounding errors (i.e. within a very small delta)
    comp.voronoi_diagram_raw.each_with_index do |computed_entry, i|
      sample_entry = example_diagram_raw[i]

      
      assert_equal computed_entry.length, sample_entry.length
      assert_equal computed_entry.first,  sample_entry.first
      
      computed_entry.each_with_index do |computed_value,j|    
        # We already tested the type...
        next if j == 0
        assert_in_delta computed_value, sample_entry[j], MAX_DELTA
      end
    end
  end
  

  def test_triangulation_correct
    # Perform the computation.
    comp = RubyVor::VDDT::Computation.from_points(sample_points)

    # One assertion:
    #  * raw triangulation must match exactly.
    
    assert_equal example_triangulation_raw, comp.delaunay_triangulation_raw
  end


  
  #
  # A few helper methods
  #
  
  private
  
  def sample_points
    # Build a sample case
    if @points.nil? || @points.empty?
      @points = []
      data = %w{ 0.0 0.0
                 0.0 0.5
                 0.5 0.0
                 3   3
                 0.5 0.5
                 5.0 5.0
                 5.0 5.5
                 5.5 5.0
                 5.5 5.5 }
      for x in 0..(data.length/2 - 1)
        @points << RubyVor::Point.new(data[x * 2].to_f, data[x * 2 + 1].to_f)
      end
    end
    @points
  end

  def example_diagram_raw
    if @diagram_raw.nil? || @diagram_raw.empty?
      @diagram_raw = [
                      [:s, 0.000000, 0.000000],
                      [:s, 0.500000, 0.000000],
                      [:l, 1.000000, 0.000000, 0.250000],
                      [:s, 0.000000, 0.500000],
                      [:l, 0.000000, 1.000000, 0.250000],
                      [:s, 0.500000, 0.500000],
                      [:l, 0.000000, 1.000000, 0.250000],
                      [:v, 0.250000, 0.250000],
                      [:l, 1.000000, 1.000000, 0.500000],
                      [:v, 0.250000, 0.250000],
                      [:e, 3, 1, 0],
                      [:l, 1.000000, 0.000000, 0.250000],
                      [:s, 3.000000, 3.000000],
                      [:l, 1.000000, 1.000000, 3.500000],
                      [:v, 3.250000, 0.250000],
                      [:e, 2, 0, 2],
                      [:l, 0.833333, 1.000000, 2.958333],
                      [:s, 5.000000, 5.000000],
                      [:l, 1.000000, 1.000000, 8.000000],
                      [:s, 5.500000, 5.000000],
                      [:l, 1.000000, 0.800000, 7.450000],
                      [:v, 5.249999, 2.750001],
                      [:l, 1.000000, 0.000000, 5.250000],
                      [:s, 5.000000, 5.500000],
                      [:l, 0.000000, 1.000000, 5.250000],
                      [:s, 5.500000, 5.500000],
                      [:l, 0.000000, 1.000000, 5.250000],
                      [:v, 5.250000, 5.250000],
                      [:e, 9, 4, 3],
                      [:l, 1.000000, 1.000000, 10.500000],
                      [:v, 5.250000, 5.250000],
                      [:e, 12, 5, 4],
                      [:l, 1.000000, 0.000000, 5.250000],
                      [:v, 0.250000, 3.250000],
                      [:e, 4, 6, 1],
                      [:e, 5, 6, 2],
                      [:l, 1.000000, 0.833333, 2.958333],
                      [:v, 2.750000, 5.250000],
                      [:e, 7, 7, 3],
                      [:e, 10, 7, 5],
                      [:l, 0.800000, 1.000000, 7.450000],
                      [:v, 15.249999, -9.749999],
                      [:e, 8, 3, 8],
                      [:e, 6, 2, 8],
                      [:l, 1.000000, 1.000000, 5.500000],
                      [:v, -9.749999, 15.249999],
                      [:e, 14, 9, 6],
                      [:e, 15, 9, 7],
                      [:l, 1.000000, 1.000000, 5.500000],
                      [:e, 1, -1, 1],
                      [:e, 17, -1, 9],
                      [:e, 13, -1, 5],
                      [:e, 11, 4, -1],
                      [:e, 16, 8, -1],
                      [:e, 0, 0, -1]
                     ]
    end
    @diagram_raw
  end

  def example_triangulation_raw
    if @trianglulation_raw.nil? || @trianglulation_raw.empty?
      @trianglulation_raw =     [
                                 [0, 4, 2],
                                 [1, 4, 0],
                                 [3, 2, 4],
                                 [5, 7, 3],
                                 [5, 8, 7],
                                 [6, 8, 5],
                                 [1, 3, 4],
                                 [3, 6, 5],
                                 [7, 2, 3],
                                 [1, 6, 3]
                                ]
    end
    @trianglulation_raw
  end
  
end

MiniTest::Unit.autorun
