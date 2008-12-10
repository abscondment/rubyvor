module RubyVor
  class PriorityQueue

    attr_reader :data, :size
    
    def initialize(d=[])
      @data = d || []
      @size = d.length

      heapify()
    end

    def peek
      @data[0]
    end

    def pop
      return nil if @size < 1
      
      r = @data[0]

      @data[0] = @data[@size-1]
      @data[0].index = 1
      @data.delete_at(@size-1)

      @size -= 1
      
      percolate_down(1) if @size > 0

      return r
    end

    def push(data, priority=Float::MAX)
      @size += 1
      @data[@size - 1] = QueueItem.new(priority, @size - 1, data)
      percolate_up(@size)
    end

    # Implemented in C
    def reorder_queue;end

    protected

    # Implemented in C
    def percolate_up(i);end

    # Implemented in C
    def percolate_down(i);end

    class QueueItem
      attr_accessor :priority, :index, :data
      def initialize(p, i, d)
        @priority = p
        @index    = i
        @data     = d
      end
    end
    
  end
end
