from collections import namedtuple
import glob
import os
import yaml
import shutil
import tempfile

import subprocess
import time
import json
import re
from typing import TypedDict
from typing import List
from typing import Tuple 

from utils import calculate_sha256, get_next_version

Package = namedtuple('Package', 'name version location title description author tags')
UploadedPackage = namedtuple('UploadedPackage', 'name version')

should_publish = os.getenv("PUBLISH", "false") == "true"


# Get the packages that have been published on the Github Releases section
def get_released_packages() -> List[UploadedPackage]:
  result = subprocess.run(['gh', 'release', 'view', "--json", "assets"], stdout=subprocess.PIPE)
  json_assets = result.stdout.decode('utf-8')
  assets = json.loads(json_assets)["assets"]

  packages = []
  for package in assets:
    file_name = package["name"]
    match = re.search('(?P<name>.*?)-(?P<version>\d+.\d+.\d+).zip', file_name)
    if match is not None:
      name = match.group("name")
      version = match.group("version")

      packages.append(UploadedPackage(name, version))

  return packages 

# Get the packages defined in the hub repository
def get_repository_packages() -> List[Package]:
  packages = []
  for path in glob.glob("packages/*/cocmd.yaml"):
    print('looking into ', path)
    package_dir = os.path.dirname(path)
    with open(path, 'r') as stream:
      try:
        manifest = yaml.safe_load(stream)
        name = manifest["name"]
        version = manifest.get("version", "0.0.0")
        package = Package(name, version, package_dir, name, name, "cocmd", [])
        packages.append(package)
      except yaml.YAMLError as exc:
        print("Exception parsing YAML ", exc)
  return packages

# Calculate which packages have NOT been published yet on Releases, 
# the ones that will need to be published during this run
def calculate_missing_packages(released: List[Package], repository: List[Package]) -> List[Package]:
  published_packages: set[str] = set()
  for package in released:
    published_packages.add(f"{package.name}@{package.version}")
  
  missing_packages = []
  for package in repository:
    package_id = f"{package.name}@{package.version}"
    if package_id not in published_packages:
      missing_packages.append(package)
  
  return missing_packages


# Archive the given package, calculating its hash
def create_archive(package: Package)-> Tuple[str, str, str]: 
  temp_dir = tempfile.gettempdir()
  target_name = os.path.join(temp_dir, f"{package.name}-{package.version}")
  shutil.make_archive(target_name, 'zip', package.location)
  
  target_file = f"{target_name}.zip"
  hash = calculate_sha256(target_file)
  target_sha_file = os.path.join(temp_dir, f"{package.name}-{package.version}-sha256.txt")

  with open(target_sha_file, "w") as file:
    file.write(hash)
  
  return (target_file, target_sha_file, hash)


# Upload the package files (archive + SHA256 sum) on GH Releases
def upload_to_releases(archive_path, archive_hash_path, release_version):
  if should_publish:
    print("Uploading to Github Releases...",  release_version)
    subprocess.run(["gh", "release", "upload", release_version, archive_hash_path, archive_path, "--clobber" ])
  else:
    print("didn't really upload")

# Generate the updated index and upload it to GH Releases
def update_index(repository: List[Package], release_version: str):
  packages = []

  for package in repository:
    packages.append({
      "name": package.name,
      "author": package.author,
      "description": package.description,
      "title": package.title,
      "version": package.version,
      "tags": package.tags,
      "archive_url": f"https://github.com/cocmd/hub/releases/latest/download/{package.name}-{package.version}.zip",
      "archive_sha256_url": f"https://github.com/cocmd/hub/releases/latest/download/{package.name}-{package.version}-sha256.txt",
    })
  
  index = {
    "last_update": round(time.time()),
    "packages": packages,
  }

  json_index = json.dumps(index)

  temp_dir = tempfile.gettempdir()
  target_file = os.path.join(temp_dir, "package_index.json")
  
  with open(target_file, "w") as file:
    file.write(json_index)

  if should_publish:
    subprocess.run(["gh", "release", "upload", release_version, target_file, "--clobber"])

release_version = "0.0.0"

print(f"will release to version: {release_version}")

subprocess.run(["gh", "release", "create", release_version])
print("Reading packages from repository...")
repository_packages = get_repository_packages()
print(f'found {len(repository_packages)} packages in this PR')

# print("Obtaining released packages from GitHub Releases...")
released_packages = get_released_packages()

print("")
print("Calculating delta...")
missing_packages = calculate_missing_packages(released_packages, repository_packages)

if len(missing_packages) == 0:
  print("Packages are already up-to-date")
  quit(0)

print("")
print("Packages to publish:")
for package in missing_packages:
  print(f"--> {package.name}@{package.version}")

  archive_path, archive_hash_path, archive_hash = create_archive(package)

  print(f"Created archive {archive_path}, hash: {archive_hash}")

  upload_to_releases(archive_path, archive_hash_path, release_version)
  print("Done!")

print("")
print("Updating index...")
update_index(repository_packages, release_version)

print("Done!")