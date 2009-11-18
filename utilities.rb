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