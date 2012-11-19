module Resque
  module Plugins
    module Async
      module Flag
        class FlaggedError < StandardError; end
        class InvalidSettingsError < StandardError; end

        def flag_enqueued_records classes_to_watch
          raise InvalidSettingsError, 'flag_enqued_records expect an array as only parameter' unless classes_to_watch.kind_of? Array
          raise InvalidSettingsError, 'flag_enqued_records expect an array of classes' unless classes_to_watch.select { |m| m.respond_to? :constantize }.empty?
          @@classes_to_watch = classes_to_watch
        end

        def classes_to_watch
          @@classes_to_watch
        end

        def flaggable? args
          classes_to_watch.include? args.first.constantize
        end

        def before_enqueue_flag_record *args
          if flaggable? args
            raise FlaggedError, 'something is being planned for this record' if flagged? args
            flag! args
          end
          true
        end

        def before_perform *args
          unflag! args
        end

        def on_failure_unflag_record *args
          unflag! args
        end

        def flag! args
          log "enqueing flaggable job for  #{redis_key args}"
          redis.set redis_key(args), 1
        end

        def flagged? args
          redis.exists redis_key(args)
        end

        def unflag! args
          log "deflagging #{redis_key args}"
          redis.del redis_key(args)
        end

        def redis_key args
          args[0..1].join '|'
        end

        private
        def redis
          @@redis ||= Resque.redis
        end

        def log message
          Rails.logger.info message
        end
      end
    end
  end
end
