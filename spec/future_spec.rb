require "spec_helper"

describe Porcupine::Future do
  let(:object) { double("future") }
  subject(:future) { described_class.new(object) }

  it "is a SimpleDelegator" do
    future.should be_a(SimpleDelegator)
  end

  describe "#get" do
    before { object.stub(:get) { "banana" } }

    it "returns the future value" do
      future.get.should == "banana"
    end

    it "raises if the value is an exception" do
      exception = RuntimeError.new
      object.stub(:get) { exception }
      expect { future.get }.to raise_error(exception)
    end
  end
end
