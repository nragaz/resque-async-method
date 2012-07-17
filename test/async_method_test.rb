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

    assert_equal true, user.long_method
    assert_equal 'success!', user.sync_long_method
  end

  test "raise error if not persisted" do
    user = User.new

    assert_raises(Resque::Plugins::Async::Method::NotPersistedError) do
      user.long_method
    end
  end

  test "lint" do
    assert_nothing_raised do
      Resque::Plugin.lint(Resque::Plugins::Async::Method)
    end
  end
end
