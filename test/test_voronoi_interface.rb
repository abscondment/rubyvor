require 'rubygems'
require 'minitest/unit'
require File.dirname(__FILE__) + '/../lib/ruby_vor'

class TestVoronoiInterface < MiniTest::Unit::TestCase
  def test_correct_triangulation
    # Perform the decomposition.
    decomp = RubyVor::VDDT::Decomposition.from_points(sample_points)

    # Compare results.
    assert_equal example_triangulation, decomp.delaunay_triangulation_raw
  end

  private
  def sample_points
    # Build a sample case
    points = []
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
      points << RubyVor::Point.new(data[x * 2].to_f, data[x * 2 + 1].to_f)
    end
    
    points
  end

  def example_triangulation
    [
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
end

MiniTest::Unit.autorun
