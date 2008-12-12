require 'rubygems'
require 'minitest/unit'
require File.dirname(__FILE__) + '/../lib/ruby_vor'

class TestPriorityQueue < MiniTest::Unit::TestCase
  
  def test_heap_order_property
    # min heap by default
    q = RubyVor::PriorityQueue.new

    items = [1,2,3,4,5,6,99,4,-20,101,5412,2,-1,-1,-1,33.0,0,55,7,12321,123.123,-123.123,0,0,0]
    items.each{|i| q.push(i)}

    items.sort!
    idx = 0

    # Test peek
    assert_equal q.peek.data, items[0]
    
    while min = q.pop
      # Test pop
      assert_equal min.data, items[idx]

      # Test peek
      assert_equal q.peek.data, items[idx + 1] if idx + 1 < items.length
      
      idx += 1
    end
  end

  def test_heapify
    q = RubyVor::PriorityQueue.new

    # Create a randomized data set.
    #
    # Not ideal for unit tests, since they *should* be done
    # on static data so that failure/success is deterministic...
    # but works for me.

    100.times{ q.push(rand * 10000.0 - 5000.0)}
      
    # Set things right.
    q.heapify()

    old_n = -1.0 * Float::MAX
    while n = q.pop
      assert n.priority >= old_n, 'Heap-order property violated'
      old_n = n.priority
    end
  end

  def test_bad_data
    q = RubyVor::PriorityQueue.new
    10.times { q.push(rand * 100.0 - 50.0) }
  
    #
    # Heapify
    #
    old_data = q.data[1]
    q.data[1] = 45
    assert_raises TypeError do
      q.heapify()
    end
    q.data[1] = old_data
    assert_nothing_raised do
      q.heapify()
    end
    

    #
    # Percolation
    #
    [100, -100].each do |i|
      assert_raises IndexError do
        q.percolate_up(i)
      end
      assert_raises IndexError do
        q.percolate_down(i)
      end
    end
    [:x, Class, nil, false].each do |i|
      assert_raises TypeError do
        q.percolate_up(i)
      end
      assert_raises TypeError do
        q.percolate_down(i)
      end
    end
    [0,1,2,3].each do |i|
      assert_nothing_raised do
        q.percolate_up(i)
      end
      assert_nothing_raised do
        q.percolate_down(i)
      end
    end
  end

  def test_build_queue
    n = 100
    
    q = RubyVor::PriorityQueue.build_queue(n) do |queue_item|
      queue_item.priority = rand * 10000.0 - 5000.0
    end

    assert_equal n, q.data.length
    assert_equal n, q.size
    
    old_n = -1.0 * Float::MAX
    while n = q.pop
      assert n.priority >= old_n, 'Heap-order property violated'
      old_n = n.priority
    end
  end
  
  private
  
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
