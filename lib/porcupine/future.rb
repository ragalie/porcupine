require "delegate"

class Porcupine
  class Future < SimpleDelegator
    def get(*args)
      result = __getobj__.get(*args)
      raise result if result.is_a?(Exception)

      result
    end
  end
end
