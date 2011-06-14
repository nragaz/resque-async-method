Resque::Plugins::Async::Method
==============================

Make Active Record instance methods asynchronous using [resque](http://www.github.com/defunkt/resque).

Works with Rails >3 and Resque >= 1.17. (Probably works with earlier versions too -- but why?)

Usage
-----

    class User < ActiveRecord::Base
      # Not needed! This is done using a hook on ActiveRecord::Base.
      # include Resque::Plugins::Async::Method
      
      def preprocess_avatar_for_a_long_time
        # do stuff
      end
      async_method :preprocess_avatar_for_a_long_time
      
      def send_a_very_long_email
        # do stuff
      end
      async_method :send_a_very_long_email, queue: 'emails'
    end
    
    u = User.find(1)
    
    u.preprocess_avatar_for_a_long_time # => queued in 'users' queue
    u.send_a_very_long_email # => queued in 'emails' queue
    u.sync_send_a_very_long_email # => happens right away!

Note that in the test environment, none of this magic happens. You can test the expected output immediately.

Method return values will change. `Resque.enqueue` will return `[]` from an async'ed method.

Sometimes it's nice to async a method that you're including from a module:

    module MyExtension
      extend ActiveSupport::Concern
      
      include Resque::Plugins::Async::Method
      
      included do
        async_method :generate_matrix, queue: 'matrices'
      end
      
      def generate_matrix
        # do stuff
      end
    end