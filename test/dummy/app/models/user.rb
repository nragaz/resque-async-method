class User < ActiveRecord::Base
  def long_method
    sleep 2
    
    return "success!"
  end
  async_method :long_method, queue: 'long-methods'
  
  def another_long_method
    sleep 2
    
    return "success!"
  end
  async_method :another_long_method
end
