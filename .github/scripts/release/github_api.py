
import subprocess

# write a function to use 
# gh release view --json tagName | jq -e .tagName
# to get the latest release version

def get_latest_release_version():
    # cmd with "| jq -e .tagName" to extract the tagName
    cmd = "gh release view --json tagName | jq -e .tagName"
    result = subprocess.run(cmd, capture_output=True)
    if result.returncode != 0:
        raise Exception(f"Failed to get latest release version: {result.stderr}")
    return result.stdout.decode("utf-8").strip()
    
    