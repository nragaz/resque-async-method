require 'resque/plugins/async/worker'

module Resque::Plugins::Async::Method
  extend ActiveSupport::Concern

  module ClassMethods
    def async_method(method_name, opts={})
      # Allow tests to call sync_ methods ...
      alias_method :"sync_#{method_name}", method_name
    
      # ... but don't actually make them asynchronous
      return if Rails.env.test?
    
      define_method "#{method_name}" do |*args|
        my_klass       = Resque::Plugins::Async::Worker
        my_klass.queue = opts[:queue] ||
                         send(:class).name.underscore.pluralize
    
        Resque.enqueue(
          my_klass,
          send(:class).name,
          send(:id),
          :"sync_#{method_name}",
          *args
        )
      end
    end
  end
end