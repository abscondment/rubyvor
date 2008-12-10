require 'rubygems'
require 'minitest/unit'
require File.dirname(__FILE__) + '/../lib/ruby_vor'

class TestPriorityQueue < MiniTest::Unit::TestCase
  
  def test_heap_order_property
    # min heap by default
    q = RubyVor::PriorityQueue.new

    items = [1,2,3,4,5,6,99,4,-20,101,5412,2,-1,-1,-1,33.0,0,55,7,12321,123.123,-123.123,0,0,0]
    items.each{|i| q.push(i,i)}

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

    ([10] * 10).each{|x| q.push(x,x)}

    q.data[3] = RubyVor::PriorityQueue::QueueItem.new(-34, 3, -34)
    q.data[4] = RubyVor::PriorityQueue::QueueItem.new(1, 4, 1)
    q.data[5] = RubyVor::PriorityQueue::QueueItem.new(100, 5, 100)
    q.data[7] = RubyVor::PriorityQueue::QueueItem.new(0.9, 7, 0.9)
    q.data.sort!{|a,b| rand(3)-1}
    
    q.heapify()

    assert_equal(-34, q.pop.data)
    assert_equal 0.9, q.pop.data
    assert_equal 1,   q.pop.data
    assert_equal 10,  q.pop.data
    assert_equal 10,  q.pop.data
    assert_equal 10,  q.pop.data
    assert_equal 10,  q.pop.data
    assert_equal 10,  q.pop.data
    assert_equal 10,  q.pop.data
    assert_equal 100, q.pop.data
  end
  
end
