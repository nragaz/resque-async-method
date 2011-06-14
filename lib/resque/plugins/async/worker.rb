class Resque::Plugins::Async::Worker
  @queue = :async_methods
  
  def self.queue=(name)
    @queue = name
  end
  
  def self.queue
    @queue
  end
  
  def self.perform(klass, *args)
    klass.constantize.find(args.shift).send(args.shift, *args)
  end
end