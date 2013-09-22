class Porcupine
  class FailedExecutionError < RuntimeError; end
  class RejectedError < RuntimeError; end
  class ShortCircuitError < RuntimeError; end
  class TimeoutError < RuntimeError; end
end
