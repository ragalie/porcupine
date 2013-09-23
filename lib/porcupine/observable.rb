require "delegate"

class Porcupine
  class Observable < SimpleDelegator
    def subscribe(*args, &block)
      raise ArgumentError unless block_given? || args.first

      on_next = if block_given?
                  block
                else
                  args.shift
                end

      on_error = !block_given? && args.shift

      wrapped = lambda do |value_or_exception|
        if value_or_exception.is_a?(Exception)
          on_error && on_error.call(value_or_exception)
        else
          on_next.call(value_or_exception)
        end
      end

      if on_error
        __getobj__.subscribe(wrapped, on_error, *args)
      else
        __getobj__.subscribe(wrapped)
      end
    end
  end
end
