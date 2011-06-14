require 'test_helper'

class AsyncMethodTest < ActiveSupport::TestCase
  test "define methods" do
    assert User.new.respond_to?(:long_method)
    assert User.new.respond_to?(:another_long_method)
    
    assert User.new.respond_to?(:sync_long_method)
    assert User.new.respond_to?(:sync_another_long_method)
  end
  
  test "enqueue jobs" do
    user = User.first
    
    assert_equal [], user.long_method
    assert_equal 'success!', user.sync_long_method
  end
end
