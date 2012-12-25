class Resque::Plugins::Async::ClassWorker
  @queue = :async_class_methods
  
  def self.queue=(name)
    @queue = name
  end
  
  def self.queue
    @queue
  end
  
  def self.perform(klass, *args)
    klass.constantize.send(args.shift, *args)
  end
end