require 'rubygems'
require 'minitest/unit'
require File.dirname(__FILE__) + '/../lib/ruby_vor'

class TestComputation < MiniTest::Unit::TestCase

  def initialize(*args)
    @points = @trianglulation_raw = @diagram_raw = nil
    super(*args)
  end

  def test_empty_points
    assert_raises TypeError do
      RubyVor::VDDT::Computation.from_points(nil)
    end
    
    assert_raises RuntimeError do
      RubyVor::VDDT::Computation.from_points([])
    end
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


    comp.nn_graph.each_with_index do |neighbors,i|
      refute_empty neighbors, "@nn_graph returned empty neighbors for node #{i}"
    end

    assert_equal comp.nn_graph.map{|v| v.sort}.sort, \
                 expected_graph.map{|v| v.sort}.sort
  end

  def test_simple_mst
    points = [
              RubyVor::Point.new(0,0),
              RubyVor::Point.new(1.0,1.1),
              RubyVor::Point.new(4.9,3.1),
             ]

    comp = RubyVor::VDDT::Computation.from_points(points)
    expected_mst = [
                    [0,1],
                    [1,2]
                   ]
    computed_mst = comp.minimum_spanning_tree
    
    # Assert nodes are correct
    assert_equal expected_mst.sort, \
                 computed_mst.keys.sort
  end
  
  def test_advanced_mst
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
                    [0,1],
                    [0,13],
                    [1,2],
                    [1,5],
                    [2,3],
                    [3,4],
                    [5,6],
                    [5,10],
                    [6,7],
                    [7,8],
                    [8,9],
                    [10,11],
                    [11,12],
                    [13,14],
                    [13,16],
                    [14,15],
                    [16,17],
                    [17,18],
                    [18,19],
                    [19,20],
                    [20,21],
                    [21,22],
                    [22,23],
                    [23,24]
                   ]
    computed_mst = comp.minimum_spanning_tree
    
    assert_equal expected_mst.sort, \
                 computed_mst.keys.sort
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

  
  def test_duplicate_points
    comp = RubyVor::VDDT::Computation.from_points([
                                                   RubyVor::Point.new(2,3),      # 0
                                                   RubyVor::Point.new(1,1),      # 1
                                                   RubyVor::Point.new(1,1),      # 2
                                                   RubyVor::Point.new(1,1),      # 3
                                                   RubyVor::Point.new(1,1),      # 4
                                                   RubyVor::Point.new(1,1),      # 5
                                                   RubyVor::Point.new(1,1),      # 6
                                                   RubyVor::Point.new(1,1),      # 7
                                                   RubyVor::Point.new(1,1),      # 8
                                                   RubyVor::Point.new(4,10),     # 9
                                                   RubyVor::Point.new(4,10.0),   # 10
                                                   RubyVor::Point.new(4.0,10.0), # 11
                                                   RubyVor::Point.new(4.0,10.0), # 12
                                                  ])
    comp.nn_graph.each_with_index do |neighbors,i|
      refute_empty neighbors, "@nn_graph has empty neighbors for node #{i}"
    end

=begin
    assert_equal [[0], [1,2,3,4,5,6,7,8], [9,10,11,12]], \
                 comp.cluster_by_distance(1).map{|cl| cl.sort}.sort, \
                 "cluster by distance 1"
    
    assert_equal [[0,1,2,3,4,5,6,7,8], [9,10,11,12]], \
                 comp.cluster_by_distance(5).map{|cl| cl.sort}.sort, \
                 "cluster by distance 5"

    assert_equal [[0,1,2,3,4,5,6,7,8,9,10,11,12]], \
                 comp.cluster_by_distance(10).map{|cl| cl.sort}.sort, \
                 "cluster by distance 10"
    
    assert_equal [[0,1,2,3,4,5,6,7,8], [9,10,11,12]], \
                 comp.cluster_by_size([2])[2].map{|cl| cl.sort}.sort, \
                 "cluster by size 2"
=end

    assert_equal [[0], [1], [2]], \
                 comp.cluster_by_distance(1).map{|cl| cl.sort}.sort, \
                 "cluster by distance 1"
    
    assert_equal [[0,1], [2]], \
                 comp.cluster_by_distance(5).map{|cl| cl.sort}.sort, \
                 "cluster by distance 5"

    assert_equal [[0,1,2]], \
                 comp.cluster_by_distance(10).map{|cl| cl.sort}.sort, \
                 "cluster by distance 10"
    
    assert_equal [[0,1], [2]], \
                 comp.cluster_by_size([2])[2].map{|cl| cl.sort}.sort, \
                 "cluster by size 2"

  end

  
  def test_bad_data
    assert_raises TypeError do
      comp = RubyVor::VDDT::Computation.from_points([RubyVor::Point.new(1,1), RubyVor::Point.new(21,3), RubyVor::Point.new(2,:s)])
    end
    
    assert_raises TypeError do
      comp = RubyVor::VDDT::Computation.from_points(RubyVor::Point.new(21,3))
    end
    
    assert_raises RuntimeError do
      comp = RubyVor::VDDT::Computation.from_points([RubyVor::Point.new(1,1), RubyVor::Point.new(21,3), nil])
    end
    
    assert_raises RuntimeError do
      comp = RubyVor::VDDT::Computation.from_points([])
    end

    comp = RubyVor::VDDT::Computation.from_points([RubyVor::Point.new(1,1), RubyVor::Point.new(21,3), RubyVor::Point.new(2,1.5)])
    assert_raises ArgumentError do
      cl = comp.cluster_by_distance(nil)
    end
  end


  def test_no_neighbors
    nn_graph = nil

    # Test :raise
    comp = RubyVor::VDDT::Computation.from_points([1,2,3,4,5].map{|xy| RubyVor::Point.new(xy,xy)})
    comp.no_neighbor_response = :raise

    assert_equal comp.no_neighbor_response, :raise    
    assert_raises(IndexError) { nn_graph = comp.nn_graph }
    assert_raises(IndexError) { comp.cluster_by_distance(5) }
    assert_equal nn_graph, nil

    
    # Test :use_all (default)
    comp = RubyVor::VDDT::Computation.from_points([1,2,3,4,5].map{|xy| RubyVor::Point.new(xy,xy)})
    comp.no_neighbor_response = :use_all

    assert_equal comp.no_neighbor_response, :use_all
    assert_nothing_raised { nn_graph = comp.nn_graph }
    assert_nothing_raised do
      assert_equal comp.cluster_by_distance(5).map{|a| a.sort}.sort, [[0,1,2,3,4]]
    end
    refute_equal nn_graph, nil

    
    # Test :ignore
    comp = RubyVor::VDDT::Computation.from_points([1,2,3,4,5].map{|xy| RubyVor::Point.new(xy,xy)})
    comp.no_neighbor_response = :ignore

    assert_equal comp.no_neighbor_response, :ignore
    assert_nothing_raised { nn_graph = comp.nn_graph }
    assert_nothing_raised do
      assert_equal comp.cluster_by_distance(5).map{|a| a.sort}.sort, [[0],[1],[2],[3],[4]]
    end
    refute_equal nn_graph, nil
  end

  
  def test_cluster_by_size
    comp = RubyVor::VDDT::Computation.from_points([
                                                   RubyVor::Point.new(0.25, 0.25),   # 0
                                                   RubyVor::Point.new(1, 0.25),      # 1
                                                   RubyVor::Point.new(0.5, 1),       # 2
                                                   RubyVor::Point.new(5, 5),         # 3
                                                   RubyVor::Point.new(10.25, 10.25), # 4
                                                   RubyVor::Point.new(13, 9),        # 5
                                                   RubyVor::Point.new(9, 9)          # 6
                                                  ])

    sizes = [1, 3, 5, 7]
    
    computed_sized_clusters = comp.cluster_by_size(sizes)

    # Check that we got clusters for each size requested
    assert_equal sizes, \
                 computed_sized_clusters.keys.sort                 

    assert_equal [[0,1,2,3,4,5,6]], \
                 computed_sized_clusters[1].map{|cl| cl.sort}.sort, \
                 'Failed cluster of size 1'
    
    assert_equal [[0,1,2], [3], [4,5,6]], \
                 computed_sized_clusters[3].map{|cl| cl.sort}.sort

    assert_equal [[0,1,2], [3], [4], [5], [6]], \
                 computed_sized_clusters[5].map{|cl| cl.sort}.sort

    assert_equal [[0], [1], [2], [3], [4], [5], [6]], \
                 computed_sized_clusters[7].sort
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
  
  def assert_nothing_raised(&b)
    begin
      yield
    rescue Exception => e
      flunk "#{mu_pp(e)} exception encountered, expected no exceptions"
      return
    end
    pass()
  end
end

MiniTest::Unit.autorun
