require 'resque-lock-timeout'

class Resque::Plugins::Async::Worker
  extend Resque::Plugins::LockTimeout

  @queue        = :async_methods
  @loner        = false
  @lock_timeout = 0
    
  class << self
        
    attr_accessor :queue
    attr_accessor :loner
    attr_accessor :lock_timeout
  
    def perform klass, *args
      klass.constantize.find(args.shift).send(args.shift, *args)
    end
  end
end