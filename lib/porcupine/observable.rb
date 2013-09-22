require "delegate"

class Porcupine
  class Observable < SimpleDelegator
    def subscribe(*args, &block)
      raise ArgumentError unless block_given? || (args.first && args.first["onNext"])

      on_next = if block_given?
                  block
                else
                  args.first["onNext"]
                end

      on_error = args.first && args.first["onError"]

      wrapped = lambda do |value_or_exception|
        if value_or_exception.is_a?(Exception)
          on_error && on_error.call(value_or_exception)
        else
          on_next.call(value_or_exception)
        end
      end

      __getobj__.subscribe("onNext" => wrapped, "onError" => on_error)
    end
  end
end
