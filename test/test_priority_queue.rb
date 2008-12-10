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
    assert_equal q.peek, items[0]
    
    while min = q.pop
      # Test pop
      assert_equal min, items[idx]

      # Test peek
      assert_equal q.peek, items[idx + 1] if idx + 1 < items.length
      
      idx += 1
    end
  end

  def test_reorder_queue
    q = RubyVor::PriorityQueue.new

    ([10] * 10).each{|x| q.push(x)}

    q.data[4] = 1
    q.data[5] = 100
    q.reorder_queue()

    assert_equal 1,   q.pop
    assert_equal 10,  q.pop
    assert_equal 10,  q.pop
    assert_equal 10,  q.pop
    assert_equal 10,  q.pop
    assert_equal 10,  q.pop
    assert_equal 10,  q.pop
    assert_equal 10,  q.pop
    assert_equal 10,  q.pop
    assert_equal 100,  q.pop
  end
  
end
