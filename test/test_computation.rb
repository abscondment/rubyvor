require 'rubygems'
require 'minitest/unit'
require File.dirname(__FILE__) + '/../lib/ruby_vor'

class TestComputation < MiniTest::Unit::TestCase

  def initialize(*args)
    @points = @trianglulation_raw = @diagram_raw = nil
    super(*args)
  end

  def test_nn_graph
    comp = RubyVor::VDDT::Computation.from_points(sample_points)

    # based on this expected delaunay trianglulation:
    #    3 2 1
    #    3 0 2
    #    8 2 0
    #    3 8 0
    #    5 6 8
    #    7 6 5
    #    7 4 6
    #    6 2 8
    #    8 7 5
    
    expected_graph = [
                      [2, 3, 8],          # 0
                      [2, 3],             # 1
                      [0, 1, 3, 6, 8],    # 2
                      [0, 1, 2, 8],       # 3
                      [6, 7],             # 4
                      [6, 7, 8],          # 5
                      [2, 4, 5, 7, 8],    # 6
                      [4, 5, 6, 8],       # 7
                      [0, 2, 3, 5, 6, 7], # 8
                     ]

    assert_equal comp.nn_graph.map{|v| v.sort}.sort, \
                 expected_graph.map{|v| v.sort}.sort
end
  
  def test_cluster_by_distance
    comp = RubyVor::VDDT::Computation.from_points(sample_points)

    expected_clusters = [
                         [0,1,2,3],
                         [8],
                         [4,5,6,7]
                        ]
    
    computed_clusters = comp.cluster_by_distance(10)
    
    assert_equal expected_clusters.map{|cl| cl.sort}.sort, \
                 computed_clusters.map{|cl| cl.sort}.sort
  end

  #
  # A few helper methods
  #

  private

  def sample_points
    if @points.nil?
      @points = [
                 [1.1,1],
                 [0,0],
                 [1,0],
                 [0,1.1],
                 
                 [101.1,101],
                 [100,100],
                 [101,100],
                 [100,101.1],

                 [43, 55]
                ].map{|x,y| RubyVor::Point.new(x,y)}
    end
    @points
  end
end

MiniTest::Unit.autorun
