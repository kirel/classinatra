# class needs a call method
module Lambdalike
  
  # (f * g)(x) = f(g(x))
  def compose other
    lambda { |*args| self.call(other.call(*args)) }
  end
  
  def * other
    compose other
  end
  
end

Proc.send :include, Lambdalike

class Array
  def rest
    self[1,self.size-1]
  end
end