require "spec_helper"

describe Porcupine do
  let(:block) { lambda {} }

  subject(:porcupine) do
    described_class.new("test", &block)
  end

  after do
    com.netflix.hystrix.Hystrix.reset
  end

  describe "#initialize" do
    it "handles a name, group, timeout and block" do
      porcupine = described_class.new("blah", "blah_group", 1_000, &block)
      porcupine.should be_a(com.netflix.hystrix.HystrixCommand)
      porcupine.getCommandKey.name.should == "blah"
      porcupine.getCommandGroup.name.should == "blah_group"
      porcupine.getProperties.executionIsolationThreadTimeoutInMilliseconds.get.should == 1_000
      porcupine.block.should == block
    end

    it "handles a setter" do
      setter = com.netflix.hystrix.HystrixCommand::Setter.withGroupKey(com.netflix.hystrix.HystrixCommandGroupKey::Factory.asKey("blah2_group"))
                                                         .andCommandKey(com.netflix.hystrix.HystrixCommandKey::Factory.asKey("blah2"))

      porcupine = described_class.new(setter, &block)
      porcupine.should be_a(com.netflix.hystrix.HystrixCommand)
      porcupine.getCommandKey.name.should == "blah2"
      porcupine.getCommandGroup.name.should == "blah2_group"
      porcupine.block.should == block
    end

    it "uses the defaults if none are provided" do
      porcupine = described_class.new("blah3", &block)
      porcupine.getCommandKey.name.should == "blah3"
      porcupine.getCommandGroup.name.should == "default"
      porcupine.getProperties.executionIsolationThreadTimeoutInMilliseconds.get.should == 10_000
      porcupine.block.should == block
    end
  end

  describe "#execute" do
    let(:future) { double("future") }

    before { porcupine.stub(:queue) { future } }

    it "calls queue.get" do
      porcupine.should_receive(:queue) { future }
      future.should_receive(:get)

      porcupine.execute
    end

    it "lets Ruby exceptions propogate" do
      future.stub(:get).and_raise(RuntimeError)
      porcupine.should_not_receive(:decomposeException)

      expect { porcupine.execute }.to raise_error(RuntimeError)
    end

    it "catches Java exceptions and runs them through #decomposeException" do
      exception = java.lang.Throwable.new
      future.stub(:get).and_raise(exception)
      porcupine.should_receive(:decomposeException).with(exception) { java.lang.Exception.new }

      expect { porcupine.execute }.to raise_error(Java::JavaLang::Exception)
    end
  end

  describe "#observe" do
    it "wraps the result in an Observable" do
      observable = porcupine.observe
      observable.should be_a(Porcupine::Observable)
      observable.__getobj__.should be_a(Java::Rx::Observable)
    end
  end

  describe "#toObservable" do
    it "wraps the result in an Observable with no args" do
      observable = porcupine.toObservable
      observable.should be_a(Porcupine::Observable)
      observable.__getobj__.should be_a(Java::Rx::Observable)
    end

    it "wraps the result in an Observable with one arg" do
      observable = porcupine.toObservable(Java::RxConcurrency::Schedulers.threadPoolForComputation)
      observable.should be_a(Porcupine::Observable)
      observable.__getobj__.should be_a(Java::Rx::Observable)
    end
  end

  describe "#queue" do
    it "wraps the result in a Future" do
      future = porcupine.queue
      future.should be_a(Porcupine::Future)
      future.__getobj__.class.ancestors.should include(Java::JavaUtilConcurrent::Future)
      future.cancel(true)
    end
  end

  describe "#run" do
    it "calls the block" do
      block.should_receive(:call)
      porcupine.run
    end
  end

  describe "#getFallback" do
    it "returns the failure exception if the block failed" do
      exception = Exception.new

      porcupine.stub(:isFailedExecution) { true }
      porcupine.stub_chain(:getFailedExecutionException, :getException) { exception }
      porcupine.getFallback.should == exception
    end

    it "returns a RejectedError if the response was rejected" do
      porcupine.stub(:isResponseRejected) { true }
      porcupine.getFallback.should be_a(Porcupine::RejectedError)
    end

    it "returns a ShortCircuitError if the response was short circuited" do
      porcupine.stub(:isResponseShortCircuited) { true }
      porcupine.getFallback.should be_a(Porcupine::ShortCircuitError)
    end

    it "returns a TimeoutError if the response timed out" do
      porcupine.stub(:isResponseTimedOut) { true }
      porcupine.getFallback.should be_a(Porcupine::TimeoutError)
    end

    it "returns a RuntimeError otherwise" do
      porcupine.getFallback.should be_a(RuntimeError)
    end
  end
end
