module RubyVor
  class PriorityQueue

    attr_reader :data, :size, :comp
    
    def initialize(comp = lambda{|a,b| a < b})
      @data = []
      @size = 0
      @comp = comp
      reorder_queue()
    end

    def peek
      @data[0]
    end

    def pop
      return nil if @size < 1
      
      r = @data[0]

      @data[0] = @data[@size-1]
      @data.delete_at(@size-1)

      @size -= 1
      
      percolate_down(1) if @size > 0

      return r
    end

    def push(v)
      @size += 1
      @data[@size - 1] = v
      percolate_up(@size)
    end

    def reorder_queue
      for i in 2..(@size) do
        percolate_up(i)
      end
    end

    protected

    def percolate_up(i)
      j = i / 2

      item = @data[i-1]

      while j > 0 && @comp[item, @data[j-1]]
        @data[i-1] = @data[j-1]
        i = j
        j = j / 2
      end

      @data[i-1] = item
    end
    
    def percolate_down(i)
      j = @size / 2
      
      item = @data[i-1]

      until i > j  
        k = i * 2
        k += 1 if k < @size && @comp[@data[k], @data[k-1]]

        if @comp[item, @data[k-1]]
          j = -1
        else
          @data[i-1] = @data[k-1]
          i = k
        end
      end

      @data[i-1] = item
    end
    
  end
end
