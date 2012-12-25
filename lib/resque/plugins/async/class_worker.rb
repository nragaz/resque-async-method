class Resque::Plugins::Async::ClassWorker
  @queue = :async_class_methods
  
  def self.queue=(name)
    @queue = name
  end
  
  def self.queue
    @queue
  end
  
  def self.perform(klass, *args)
    arguments = args.map { |arg|
      if arg.is_a?(Hash) && arg.has_key?("_obj_class_name") && arg.has_key?("_obj_id")
        arg["_obj_class_name"].constantize.find(arg["_obj_id"])
      else
        arg
      end
    }
    klass.constantize.send(arguments.shift, *arguments)
  end
end