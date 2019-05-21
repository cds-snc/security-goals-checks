require "spec"
require "../src/url_contains"

describe UrlContains do
  describe "#check" do
    it "requires the URL to be set" do
      UrlContains.check.should eq 1
    end

    it "requires the NEEDLE to be set" do
      ENV["URL"] = "goo"
      UrlContains.check.should eq 1
    end

  end
end