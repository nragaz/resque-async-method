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

  test "enqueue class jobs" do
    assert_equal true, User.class_method_is_awesome
    assert_equal "success!", User.sync_class_method_is_awesome
  end

  test "enqueue class jobs with params" do
    assert_equal true, User.class_methods_with_awesome_vars(1,2)
    assert_equal 3, User.sync_class_methods_with_awesome_vars(1,2)
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
