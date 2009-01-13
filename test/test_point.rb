require 'rubygems'
require 'minitest/unit'
require File.dirname(__FILE__) + '/../lib/ruby_vor'

class TestPoint < MiniTest::Unit::TestCase

  def test_instantiation
    a = b = nil
    
    assert_raises TypeError do
      a = RubyVor::Point.new(:"10", 10)
    end
    
    assert_raises TypeError do
      a = RubyVor::Point.new(10, :"10")
    end
    
    assert_nothing_raised do
      a = RubyVor::Point.new(123.456, 789.10)
      b = RubyVor::Point.new("123.456", "789.10")
    end

    assert_equal a, b
  end
  
  def test_comparison
    a = RubyVor::Point.new(10, 10)
    b = RubyVor::Point.new(1,  1)

    assert a > b
    assert b < a
    assert_equal(-1, (b <=> a))
  end

  def test_equality
    a = RubyVor::Point.new(10,   10)
    b = RubyVor::Point.new(10.0, 10)
    c = RubyVor::Point.new(10.0, 10.0)
    d = RubyVor::Point.new(10,   10.0)
    
    z = RubyVor::Point.new(Math::PI, Math::PI)
    o = a

    
    # Test equality of values; both == and eql? perform this function.
    assert a == a
    assert a == b
    assert a == c
    assert a == d
    assert a == o
    assert a.eql?(a)
    assert a.eql?(b)
    assert a.eql?(c)
    assert a.eql?(d)
    assert a.eql?(o)
    
    refute a == z
    refute a.eql?(z)
    

    # Test object equality.
    refute a.equal?(b)
    refute a.equal?(c)
    refute a.equal?(d)
    refute a.equal?(z)
    
    assert a.equal?(a)
    assert a.equal?(o)
  end

  def test_hash
    a = RubyVor::Point.new(10,   10)
    b = RubyVor::Point.new(10.0, 10)
    c = RubyVor::Point.new(10.0, 10.0)
    d = RubyVor::Point.new(10,   10.0)
    
    z = RubyVor::Point.new(Math::PI, Math::PI)
    o = a

    assert_equal a.hash, b.hash
    assert_equal a.hash, c.hash
    assert_equal a.hash, d.hash
    assert_equal a.hash, o.hash

    refute_equal a.hash, z.hash
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
