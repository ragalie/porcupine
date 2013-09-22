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
    let(:arguments) { observable.subscribe("onNext" => on_next, "onError" => on_error) }

    describe "arguments" do
      it "accepts a block" do
        observable.subscribe {}
      end

      it "accepts an onNext parameter" do
        observable.subscribe("onNext" => lambda {})
      end

      it "raises otherwise" do
        expect { observable.subscribe("cat!") }.to raise_error(ArgumentError)
      end
    end

    it "calls subscribe with a block" do
      object.stub(:subscribe) {|arg| arg}
      observable.subscribe(&on_next)
      arguments["onNext"].call(1).should == "pumpkin"
    end

    it "calls subscribe with the provided onNext method" do
      object.stub(:subscribe) {|arg| arg}
      arguments["onNext"].call(1).should == "pumpkin"
    end

    it "calls subscribe with the provided onError method" do
      object.stub(:subscribe) {|arg| arg}
      arguments["onError"].should == on_error
    end

    describe "onNext method" do
      before { object.stub(:subscribe) {|arg| arg} }

      it "calls the success method" do
        wrapped = arguments["onNext"]

        on_next.should_receive(:call).with("pony")
        wrapped.call("pony")
      end

      it "calls the error method if the value is an exception" do
        wrapped = arguments["onNext"]

        exception = RuntimeError.new
        on_error.should_receive(:call).with(exception)
        wrapped.call(exception)
      end

      it "does nothing if there's no on_error" do
        arguments = observable.subscribe(&on_next)
        wrapped = arguments["onNext"]

        exception = RuntimeError.new
        on_error.should_not_receive(:call)
        on_next.should_not_receive(:call)
        wrapped.call(exception)
      end
    end
  end
end
