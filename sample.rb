class Worm
  
  include Enumerable
  
  def initialize l
    @max_lenght = l
    @a = []
  end

  def each &block
    @a.each &block
  end
    
  def << elem
    @a.shift if @a.size == @max_lenght
    @a << elem
    return self
  end
  
  def push elem
    @a << elem
    @a.shift if @a.size > @max_lenght
  end    
end

class CappedContainer

  include Enumerable

  def initialize limit
    # @limit = limit
    @hash = Hash.new { |h,v| h[v] = Worm.new limit }
  end

  def << sample # wich is a Sample
    a = @hash[sample.id]
    a << sample
    self
  end  
  
  def push sample
    a = @hash[sample.id]
    a.push sample    
  end

  def each &block
    @hash.each do |id, ary|
      ary.each do |sample|
        yield sample
      end
    end
  end

end # CappedContainer

Sample = Struct.new(:id, :data, :sample_id)