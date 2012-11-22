require 'resque-async-method/version'
require 'active_support/concern'
require 'active_support/dependencies/autoload'

module Resque
  module Plugins
    module Async
      autoload :Method, 'resque/plugins/async/method'
      autoload :Worker, 'resque/plugins/async/worker'
    end
  end
end

ActiveSupport.on_load(:active_record) do
  include Resque::Plugins::Async::Method
end