require 'resque/plugins/async/worker'

module Resque::Plugins::Async::Method
  extend ActiveSupport::Concern

  class NotPersistedError < StandardError; end

  module ClassMethods
    
    def async_method method_name, options = {}
      
      puts "options => #{options}"
      alias_method :"sync_#{method_name}", method_name # Allow tests to call sync_ methods ...

      return if Rails.env.test? # ... but don't actually make them asynchronous

      define_method method_name do |*args|
        raise NotPersistedError, "Methods can only be async'ed on persisted records (currently: #{inspect})" unless self.persisted?

        my_klass              = Resque::Plugins::Async::Worker
        my_klass.queue        = options[:queue] || __send__(:class).name.underscore.pluralize.to_sym
        my_klass.loner        = options[:loner] || false
        my_klass.lock_timeout = options[:lock_timeout] || 0
        my_klass.loner = true if my_klass.lock_timeout > 0 # Magick config

        Resque.enqueue(
          my_klass,
          __send__(:class).name,
          __send__(:id),
          "sync_#{method_name}".to_sym,
          *args
        )
      end
    end
  end
end