require 'securerandom'

module Resque
  module Plugins
    module Fifo
      class Worker < Resque::Worker
        UPDATE_DELAY = 10
        attr_accessor :main_queue_name

        def queues=(queues)
          queues = queues.empty? ? (ENV["QUEUES"] || ENV['QUEUE']).to_s.split(',') : queues
          @main_queue_name = "#{manager.queue_prefix}-#{SecureRandom.hex(10)}"

          @queues = ([:fifo_refresh, main_queue_name] + queues).map { |queue| queue.to_s.strip }
          unless ['*', '?', '{', '}', '[', ']'].any? { |char| @queues.join.include?(char) }
            @static_queues = @queues.flatten.uniq
          end
          validate_queues
        end

        # Attempts to grab a job off one of the provided queues. Returns
        # nil if no job can be found.
        def reserve
          queues.each do |queue|
            log_with_severity :debug, "Checking #{queue}"
            if job = Resque.reserve(queue)
              log_with_severity :debug, "Found job on #{queue}"

              if job['enqueue_ts']
                delay_ts = Time.now.to_i - job['enqueue_ts']
                max_delay = redis_client.get("queue-stats-max-delay") || 0
                redis_client.incr("queue-stats-accumulated-delay", delay_ts)
                redis_client.incr("queue-stats-accumulated-count")
                if (delay_ts > max_delay)
                  redis_client.set("queue-stats-max-delay", max_delay)
                end
              end
              return job
            end
          end

          nil
        rescue Exception => e
          log_with_severity :error, "Error reserving job: #{e.inspect}"
          log_with_severity :error, e.backtrace.join("\n")
          raise e
        end

        # Registers ourself as a worker. Useful when entering the worker
        # lifecycle on startup.
        def register_worker
          super

          puts "Fifo Startup - Updating worker list"
          manager.request_refresh
        end

        def unregister_worker(exception = nil)
          super(exception)

          puts "Fifo Shutdown - Updating worker list"
          manager.request_refresh
        end

        private

        def manager
          @manager ||=  Resque::Plugins::Fifo::Queue::Manager.new
        end
      end
    end
  end
end
