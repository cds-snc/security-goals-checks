require "http/client"
require "json"
require "uuid"
require "uuid/json"

module HttpsScan
  extend self

  def check
    begin

      ENV["ORIGIN"]      ||= "Missing origin"
      ENV["COMPONENT"]   ||= "Missing componet"
      ENV["DESCRIPTION"] ||= "Missing description"
      ENV["OUT_PATH"]    ||= "/checks/"
      ENV["SATISFIES"]   ||= ""
      ENV["RELEASE"]     ||= ""
      ENV["DOMAIN"]      ||= ""
      ENV["SCAN_URL"]    ||= "https://cache-test-q22x7kkp6a-uc.a.run.app/scan/"

      check = {
        "origin"      => ENV["ORIGIN"],
        "component"   => ENV["COMPONENT"],
        "description" => ENV["DESCRIPTION"],
        "path"        => ENV["OUT_PATH"],
        "satisfies"   => ENV["SATISFIES"],
        "release"     => ENV["RELEASE"],
        "domain"      => ENV["DOMAIN"],
        "passed"      => "false"
      } 

      if check["domain"] == ""
        puts "DOMAIN not defined"
        return 1
      end

      context = OpenSSL::SSL::Context::Client.insecure
      url = URI.parse(ENV["SCAN_URL"] + check["domain"])
      client = HTTP::Client.new(url.host.to_s, tls: context)
      res = client.get(url.full_path)

      if res.status_code < 400
        body = JSON.parse(res.body)
        if body["COMPLIANCE_ISSUES"].size == 0
          check["passed"] = "true"
        end
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
            json.field "references", check["domain"]
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
  