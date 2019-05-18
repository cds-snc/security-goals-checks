import datetime
import json
import os
import subprocess
import uuid
import yaml

origin = os.getenv("ORIGIN", "Missing origin")
component = os.getenv("COMPONENT", "Missing componet")
description = os.getenv("DESCRIPTION", "Missing description")
path = os.getenv("OUT_PATH", "/checks/")
satisfies = os.getenv("SATISFIES", "")
release = os.getenv("RELEASE", False)
domain = os.getenv("DOMAIN_NAME", False)

if domain:
    output = subprocess.check_output(["./kube-hunter.py", "--remote", domain, "--report", "yaml", "--log", "NONE"])
else:
    output = subprocess.check_output(["./kube-hunter.py", "--pod", "--report", "yaml", "--log", "NONE"])
    
obj = yaml.load(output, Loader=yaml.FullLoader)

if len(obj["vulnerabilities"]) == 0:
    passed = "true"
else:
    passed = "false"

vulnerabilities = map(lambda v: v["category"] + ": " + v["vulnerability"] + " - " + v["description"], obj["vulnerabilities"])   

check = {
    "origin": origin,
    "component": component,
    "description": description,
    "satisfies": satisfies.split(","),
    "release": release,
    "passed": passed,
    "timestamp": datetime.datetime.utcnow().isoformat("T") + "Z",
    "references": json.dumps(vulnerabilities)
}

print check

if release:
    file_name = path + str(uuid.uuid4()) + ".json"
    f = open(file_name, "a")
    f.write(json.dumps(check))
    f.close()
