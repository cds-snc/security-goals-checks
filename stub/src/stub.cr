require "json"
require "uuid"
require "uuid/json"

module Stub
  extend self

  def check
    begin
      
      ENV["ORIGIN"]      ||= "Missing origin"
      ENV["COMPONENT"]   ||= "Missing componet"
      ENV["DESCRIPTION"] ||= "Missing description"
      ENV["OUT_PATH"]    ||= "/checks/"
      ENV["SATISFIES"]   ||= ""
      ENV["RELEASE"]     ||= ""

      check = {
        "origin"      => ENV["ORIGIN"],
        "component"   => ENV["COMPONENT"],
        "description" => ENV["DESCRIPTION"],
        "path"        => ENV["OUT_PATH"],
        "satisfies"   => ENV["SATISFIES"],
        "release"     => ENV["RELEASE"],
        "passed"      => "false"
      } 

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
          end
        end
        uuid = UUID.random()
        File.write(check["path"] + uuid.to_s + ".json", json_data)
      end

      return 0
    rescue ex
      puts ex.message
      return 1
    end
  end
end
