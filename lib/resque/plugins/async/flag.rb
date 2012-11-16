module Resque
  module Plugins
    module Async
      module Flag
        
        def flag_enqueued_records classes_to_watch
          raise 'flag_enqued_records expect an array as only parameter' unless classes_to_watch.kind_of? Array
          raise 'flag_enqued_records expect an array of classes' unless classes_to_watch.select { |m| m.respond_to? :constantize }.empty?
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
            Rails.logger.info 'enqueing flaggable state change'
            raise 'something is being planned for this record' if flagged? args
            flag! args
          else
            Rails.logger.info 'enqueuing not a consultation'
          end
          true
        end

        def before_perform *args
          Rails.logger.info "deflagging #{redis_key args}"
          unflag! args
        end
        
        def on_failure_unflag_record *args
          Rails.logger.info "deflagging #{redis_key args}"
          unflag! args
        end

        def flag! args
          redis.set redis_key(args), 1
        end

        def flagged? args
          redis.exists redis_key(args)
        end

        def unflag! args
          redis.del redis_key(args)
        end

        def redis_key args
          args[0..1].join '|'
        end

        def redis
          @@redis ||= Resque.redis
        end
        
      end
    end
  end
end
