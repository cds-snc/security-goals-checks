require "spec"
require "../src/https_scan"

describe HttpsScan do
  describe "#check" do
    it "requires the DOMAIN to be set" do
      HttpsScan.check.should eq 1
    end

  end
end