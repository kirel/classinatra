# class needs a call method
module Lambdalike
  
  # (f * g)(x) = f(g(x))
  def compose other
    lambda { |*args| self.call(other.call(*args)) }
  end
  
  def * other
    compose other
  end
  
  def to_proc
    lambda { |*args| self.call *args }
  end
  
end

Proc.send :include, Lambdalike

class Array
  def rest
    self[1,self.size-1]
  end
end

class Hash
  # combines like merge-with from Clojure
  
  # Returns a map that consists of the rest of the maps conj-ed onto
  # the first.  If a key occurs in more than one map, the mapping(s)
  # from the latter (left-to-right) will be combined with the mapping in
  # the result by calling (f val-in-result val-in-latter).
  def update_with(*hashes, &block)
    hashes.each do |h|
      h.each do |k,v|
        self[k] = if self[k]
                    yield(self[k], v)
                  else
                    v
                  end 
      end
    end
    self
  end
  
  def merge_with(*hashes, &block)
    self.dup.update_with(*hashes, &block)
  end
end