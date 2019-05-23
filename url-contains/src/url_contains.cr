require "http/client"
require "json"
require "uuid"
require "uuid/json"

module UrlContains
  extend self

  def check
    begin
      
      ENV["ORIGIN"]      ||= "Missing origin"
      ENV["COMPONENT"]   ||= "Missing componet"
      ENV["DESCRIPTION"] ||= "Missing description"
      ENV["OUT_PATH"]    ||= "/checks/"
      ENV["SATISFIES"]   ||= ""
      ENV["RELEASE"]     ||= ""
      ENV["URL"]         ||= ""
      ENV["NEEDLE"]      ||= ""

      check = {
        "origin"      => ENV["ORIGIN"],
        "component"   => ENV["COMPONENT"],
        "description" => ENV["DESCRIPTION"],
        "path"        => ENV["OUT_PATH"],
        "satisfies"   => ENV["SATISFIES"],
        "release"     => ENV["RELEASE"],
        "url"         => ENV["URL"],
        "needle"      => ENV["NEEDLE"],
        "passed"      => "false"
      } 

      if check["url"] == ""
        puts "URL not defined"
        return 1
      end

      if check["needle"] == ""
        puts "NEEDLE not defined"
        return 1
      end

      context = OpenSSL::SSL::Context::Client.insecure
      url = URI.parse(check["url"])
      client = HTTP::Client.new(url.host.to_s, tls: context)
      res = client.get(url.full_path)

      if res.status_code < 400

        check["passed"] = res.body.index(check.["needle"]) != nil ? "true" : "false"
      end

      puts check

      if check["release"] != ""
        json_data = JSON.build do |json|
          json.object do
            json.field "origin", check["origin"]
            json.field "component", check["component"]
            json.field "description", check["description"]
            json.field "satisfies", check["satisfies"].split(",")
            json.field "release", check["release"]
            json.field "passed", check["passed"]
            json.field "timestamp", Time.now.to_rfc3339
            json.field "references", check["needle"]
          end
        end
        uuid = UUID.random()
        File.write(check["path"] + uuid.to_s + ".json", json_data)
      end

    rescue ex
      puts ex.message
      return 1
    end
  end
end
