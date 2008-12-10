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

  def test_mst
    # Test tree taken from an example SVG included in the Wikipedia article on Euclidean minimum spanning trees:
    # http://en.wikipedia.org/wiki/Image:Euclidean_minimum_spanning_tree.svg
    
    points = [
              RubyVor::Point.new(155.692, 99.783),  # 0
              RubyVor::Point.new(162.285, 120.245), # 1
              RubyVor::Point.new(143.692, 129.893), # 2
              RubyVor::Point.new(150.128, 167.924), # 3
              RubyVor::Point.new(137.617, 188.953), # 4
              RubyVor::Point.new(193.467, 119.345), # 5
              RubyVor::Point.new(196.754, 88.47),   # 6
              RubyVor::Point.new(241.629, 70.845),  # 7
              RubyVor::Point.new(262.692, 59.97),   # 8
              RubyVor::Point.new(269.629, 63.158),  # 9
              RubyVor::Point.new(247.257, 200.669), # 10
              RubyVor::Point.new(231.28, 245.974),  # 11
              RubyVor::Point.new(268.002, 264.693), # 12
              RubyVor::Point.new(155.442, 64.473),  # 13
              RubyVor::Point.new(198.598, 31.804),  # 14
              RubyVor::Point.new(216.816, 3.513),   # 15
              RubyVor::Point.new(89.624, 27.344),   # 16
              RubyVor::Point.new(67.925, 56.999),   # 17
              RubyVor::Point.new(77.328, 93.404),   # 18
              RubyVor::Point.new(65.525, 158.783),  # 19
              RubyVor::Point.new(63.525,170.783),   # 20
              RubyVor::Point.new(15.192, 192.783),  # 21
              RubyVor::Point.new(7.025, 236.949),   # 22
              RubyVor::Point.new(40.525, 262.949),  # 23
              RubyVor::Point.new(61.692, 225.95)    # 24
             ]
    
    comp = RubyVor::VDDT::Computation.from_points(points)

    expected_mst = [
                    [1,13],    # 0
                    [0,2,5],   # 1
                    [1,3],     # 2
                    [2,4],     # 3
                    [3],       # 4
                    [1,6,10],  # 5
                    [5,7],     # 6
                    [6,8],     # 7
                    [7,9],     # 8
                    [8],       # 9
                    [5,11],    # 10
                    [10,12],   # 11
                    [11],      # 12
                    [0,14,16], # 13
                    [13,15],   # 14
                    [14],      # 15
                    [13,17],   # 16
                    [16,18],   # 17
                    [17,19],   # 18
                    [18,20],   # 19
                    [19,21],   # 20
                    [20,22],   # 21
                    [21,23],   # 22
                    [22,24],   # 23
                    [23]       # 24
                   ]
    assert_equal expected_mst.map{|v| v.sort}.sort, \
                 comp.minimum_spanning_tree.map{|v| v.sort}.sort
  end
  
  def test_cluster_by_distance
    comp = RubyVor::VDDT::Computation.from_points(sample_points)
    
    expected_clusters = [
                         [0,1,2,3],
                         [8],
                         [4,5,6,7]
                        ]

    # We want to ensure that the nn_graph isn't modified by this call
    original_nn_graph = comp.nn_graph.map{|v| v.clone}

    # Compute clusters within a distance of 10
    computed_clusters = comp.cluster_by_distance(10)
    
    assert_equal expected_clusters.map{|cl| cl.sort}.sort, \
                 computed_clusters.map{|cl| cl.sort}.sort

    assert_equal original_nn_graph, \
                 comp.nn_graph

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
