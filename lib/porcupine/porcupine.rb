class Porcupine < com.netflix.hystrix.HystrixCommand
  java_import com.netflix.hystrix.HystrixCommand::Setter
  java_import com.netflix.hystrix.HystrixCommandKey
  java_import com.netflix.hystrix.HystrixCommandGroupKey
  java_import com.netflix.hystrix.HystrixCommandProperties

  DEFAULT_TIMEOUT = 10_000
  DEFAULT_GROUP   = "default"

  attr_reader :block

  def initialize(name_or_setter, group=DEFAULT_GROUP, timeout=DEFAULT_TIMEOUT, &block)
    @block = block

    setter = name_or_setter if name_or_setter.is_a?(com.netflix.hystrix.HystrixCommand::Setter)
    setter ||= Setter.withGroupKey(HystrixCommandGroupKey::Factory.asKey(group))
                     .andCommandKey(HystrixCommandKey::Factory.asKey(name_or_setter))
                     .andCommandPropertiesDefaults(HystrixCommandProperties::Setter().withExecutionIsolationThreadTimeoutInMilliseconds(timeout))

    super(setter)
  end

  # Only catch Java exceptions since we already handle most exceptions in Observable#get
  def execute
    queue.get
  rescue Java::JavaLang::Throwable => e
    raise decomposeException(e)
  end

  def observe
    Observable.new(super)
  end

  # Only wrap the outer-most call; otherwise Java gets angry because the class of the
  # returned object won't match the signature when the calls recurse
  def toObservable(*args)
    result = super

    unless caller.first.match(/toObservable/) || caller.first.match(/observe/)
      result = Observable.new(result)
    end

    result
  end

  def queue
    Future.new(super)
  end

  def run
    block.call
  end

  def getFallback
    return getFailedExecutionException.getException if isFailedExecution
    return RejectedError.new                        if isResponseRejected
    return ShortCircuitError.new                    if isResponseShortCircuited
    return TimeoutError.new                         if isResponseTimedOut
    RuntimeError.new
  end
end
