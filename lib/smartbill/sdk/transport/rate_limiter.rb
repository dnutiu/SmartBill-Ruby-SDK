# frozen_string_literal: true

module Smartbill
  module Sdk
    module Transport
      # Simple token-bucket limiter: +max_calls+ per +window_seconds+.
      #
      # Optionally enabled by clients to preempt the server's 403.
      class RateLimiter
        attr_reader :max_calls, :window_seconds

        def initialize(max_calls: 30, window_seconds: 10.0)
          @max_calls = max_calls
          @window_seconds = window_seconds
          @timestamps = []
          @blocked_until = 0.0
        end

        # Raise {RateLimitError} if calling now would exceed the limit.
        def acquire
          now = Process.clock_gettime(Process::CLOCK_MONOTONIC)
          if now < @blocked_until
            wait = @blocked_until - now
            raise RateLimitError, format("Client-side rate limit: would block for %.1fs.", wait)
          end
          prune(now)
          if @timestamps.size >= @max_calls
            @blocked_until = @timestamps.first + @window_seconds
            wait = @blocked_until - now
            raise RateLimitError, format("Client-side rate limit exceeded: would block for %.1fs.", wait)
          end
          @timestamps << now
        end

        # Record a server-side 403 so the limiter backs off for 10 minutes.
        def notify_403
          @blocked_until = Process.clock_gettime(Process::CLOCK_MONOTONIC) + 600.0
        end

        private

        def prune(now)
          cutoff = now - @window_seconds
          @timestamps.select! { |t| t >= cutoff }
        end
      end
    end
  end
end
