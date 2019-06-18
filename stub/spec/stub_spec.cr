require "spec"
require "../src/stub"

describe Stub do
  describe "#check" do
    it "should just pass" do
      Stub.check.should eq 0
    end
  end
end