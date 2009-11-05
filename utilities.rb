module Lambdalike
  
  # (f * g)(x) = f(g(x))
  def compose other
    ->(*args) { self.call(other.call(*args)) }
  end
  
  def * other
    compose other
  end
  
end