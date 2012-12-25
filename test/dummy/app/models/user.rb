class User < ActiveRecord::Base

  def User.class_method_is_awesome
    return "success!"
  end

  async_class_method :class_method_is_awesome

  def User.class_methods_with_awesome_vars(num1, num2)
    return num1.to_i + num2.to_i
  end

  async_class_method :class_methods_with_awesome_vars
  
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
