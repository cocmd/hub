
import os
from typing import List, Optional


def validate_package(path: str) -> Optional[str]:
    if not os.path.isdir(path):
        raise Exception(f"the given path is not a directory: {path}")

    command = f"cocmd install -y {path}"
    
    # run the command and if it fails, return the error message
    # otherwise return None

    status = os.system(command)
    if status != 0:
        return f"Command \"\"failed with status {status}"
    
    
          