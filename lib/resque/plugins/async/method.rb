require 'resque/plugins/async/worker'

module Resque::Plugins::Async::Method
  extend ActiveSupport::Concern

  class NotPersistedError < StandardError; end

  module ClassMethods

    def async_class_method(method_name, opts={})
      # Allow tests to call sync_ methods ...

      eval(%Q{
      class << self
        alias_method :sync_#{method_name}, :#{method_name}
      end})

      # ... but don't actually make them asynchronous
     # return if Rails.env.test?
      define_singleton_method "#{method_name}" do |*args|
        
        my_klass       = Resque::Plugins::Async::ClassWorker
        my_klass.queue = opts[:queue] ||
                         send(:class).name.underscore.pluralize

        # Convert AR::Base params to hash directive, restored in Worker and ClassWorker
        *args = *args.map do |arg|
          if arg.kind_of?(ActiveRecord::Base)
            {"_obj_class_name" => arg.class.name, "_obj_id" => arg.id}
          else
            arg
          end
        end

        Resque.enqueue(
          my_klass,
          self.name,
          :"sync_#{method_name}",
          *args
        )
      end
    end

    def async_method(method_name, opts={})
      # Allow tests to call sync_ methods ...
      alias_method :"sync_#{method_name}", method_name

      # ... but don't actually make them asynchronous
      return if Rails.env.test?

      define_method "#{method_name}" do |*args|
        raise NotPersistedError, "Methods can only be async'ed on persisted records (currently: #{inspect})" unless persisted?

        my_klass       = Resque::Plugins::Async::Worker
        my_klass.queue = opts[:queue] ||
                         send(:class).name.underscore.pluralize

        *args = *args.map do |arg|
          if arg.kind_of?(ActiveRecord::Base)
            {"_obj_class_name" => arg.class.name, "_obj_id" => arg.id}
          else
            arg
          end
        end
        
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