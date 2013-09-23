require "spec_helper"

describe Porcupine::Observable do
  let(:object) { double("observable", :subscribe => nil) }
  subject(:observable) { described_class.new(object) }

  it "is a SimpleDelegator" do
    observable.should be_a(SimpleDelegator)
  end

  describe "#subscribe" do
    let(:on_next) { lambda {|v| "pumpkin" } }
    let(:on_error) { lambda {|v| "apples" } }
    let(:arguments) { observable.subscribe(on_next, on_error) }

    describe "arguments" do
      it "accepts a block" do
        observable.subscribe {}
      end

      it "accepts a parameter" do
        observable.subscribe(lambda {})
      end

      it "raises otherwise" do
        expect { observable.subscribe }.to raise_error(ArgumentError)
      end
    end

    it "calls subscribe with a block" do
      object.stub(:subscribe) {|*args| args}
      observable.subscribe(&on_next)
      arguments.first.call(1).should == "pumpkin"
    end

    it "calls subscribe with the provided onNext method" do
      object.stub(:subscribe) {|*args| args}
      arguments.first.call(1).should == "pumpkin"
    end

    it "calls subscribe with the provided onError method" do
      object.stub(:subscribe) {|*args| args}
      arguments[1].should == on_error
    end

    describe "onNext method" do
      before { object.stub(:subscribe) {|*args| args} }

      it "calls the success method" do
        wrapped = arguments.first

        on_next.should_receive(:call).with("pony")
        wrapped.call("pony")
      end

      it "calls the error method if the value is an exception" do
        wrapped = arguments.first

        exception = RuntimeError.new
        on_error.should_receive(:call).with(exception)
        wrapped.call(exception)
      end

      it "passes in the complete method if provided" do
        on_complete = lambda { "pears" }
        object.should_receive(:subscribe).with(kind_of(Proc), on_error, on_complete)
        observable.subscribe(on_next, on_error, on_complete)
      end

      it "does nothing if there's no on_error" do
        arguments = observable.subscribe(&on_next)
        wrapped = arguments.first

        exception = RuntimeError.new
        on_error.should_not_receive(:call)
        on_next.should_not_receive(:call)
        wrapped.call(exception)
      end
    end
  end
end
