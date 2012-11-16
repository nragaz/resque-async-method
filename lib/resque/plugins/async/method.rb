require 'resque/plugins/async/worker'
require 'resque/plugins/async/flag'

module Resque::Plugins::Async::Method
  extend ActiveSupport::Concern

  class NotPersistedError < StandardError; end

  module ClassMethods
    
    def async_method(method_name, opts={})
      
      alias_method :"sync_#{method_name}", method_name # Allow tests to call sync_ methods ...

      return if Rails.env.test? # ... but don't actually make them asynchronous

      define_method "#{method_name}" do |*args|
        raise NotPersistedError, "Methods can only be async'ed on persisted records (currently: #{inspect})" unless persisted?

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