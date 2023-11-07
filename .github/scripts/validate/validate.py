
import os
from typing import List, Optional
import yaml


def validate_package(path: str) -> Optional[str]:
    if not os.path.isdir(path):
        raise Exception(f"the given path is not a directory: {path}")

    command = f"cocmd install -y {path}"
    
    # run the command and if it fails, return the error message
    # otherwise return None

    status = os.system(command)
    if status != 0:
        return f"Command \"\"failed with status {status}"
    
    # read cocmd.yaml file and check for the "name" field value 
    # keep the value of "name" in a variable
    # read the file with lib yaml
    name = None
    with open(f"{path}/cocmd.yaml", 'r') as stream:
        try:
            manifest = yaml.safe_load(stream)
            name = manifest["name"]
        except yaml.YAMLError as exc:
            return f"Exception parsing YAML {str(exc)}"
    
    # now we run a check to see what was loaded
    # if the package was loaded, then we are good
    # in the "cocmd show package ..." output we must see
    # at least the word "aliases", "PATH additions" or "automations"
    # and also we must see "-location:"
    
    command = f"cocmd docs --raw-markdown {name}"
    output = os.popen(command).read()
    print(output)
    
    if "aliases" not in output and "PATH additions" not in output and "automations" not in output:
        return f"Package looks empty. Please check the output of the command: {command}: \n output"
    
    if "location:" not in output:
        return f"Package was not loaded. Please check the output of the command: {command}: \n output"
    
    
          