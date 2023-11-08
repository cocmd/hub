

import hashlib

# Calculate SHA256 of the given file 
def calculate_sha256(filename) -> str:
  sha256_hash = hashlib.sha256()
  with open(filename,"rb") as f:
    for byte_block in iter(lambda: f.read(4096),b""):
      sha256_hash.update(byte_block)
    return sha256_hash.hexdigest()
  
  
def get_next_version(current_xyz_ver: str)->str:
  # split the version string into its components
  # and increment the patch version
  # then reassemble the string and return it
  
  # split the version string into its components
  # and increment the patch version

  parts = current_xyz_ver.split(".")
  major = int(parts[0])
  minor = int(parts[1])
  patch = int(parts[2])
  patch += 1
  
  # then reassemble the string and return it
  return f"{major}.{minor}.{patch}"