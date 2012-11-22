Resque::Plugins::Async::Method
==============================

Make Active Record instance methods asynchronous using [resque](http://www.github.com/defunkt/resque).

Works with Ruby ~> 1.9, Rails ~> 3 and Resque ~> 1.17. (Probably works with earlier versions too -- but why?)

Usage
-----

    class User < ActiveRecord::Base
      # Not needed! This is done using a hook on ActiveRecord::Base.
      # include Resque::Plugins::Async::Method

      def process_avatar
        # do stuff
      end
      async_method :process_avatar

    end

    u = User.find(1)

    u.process_avatar # => queued in 'users' queue

	# You can call previous method in sync mode by :
    u.sync_process_avatar # => happens right away!

Note that in the test environment, none of this magic happens. You can test the expected output immediately.

Method return values will change. `Resque.enqueue` will return `[]` from an async'ed method.

## In Module extension

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

# Concurrently protection

You can protect for concurrently processing in background

For this, you must indicate which classes should not make any treatment concurrently :

	unless Resque.inline?
		class Resque::Plugins::Async::Worker
			extend Resque::Plugins::Async::Flag
			flag_enqueued_records [ MyAwesomeClass ]
		end
	end

place this code in your initializer, for example :

	app/config/resque-async-method.rb

Changelog
---------
* 1.2: Add flaging system
* 1.1.1: Switch to Rspec test suite.
* 1.0.1: Update for latest Resque API (true returned from successful queue)
* 1.0.0: Initial release