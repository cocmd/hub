import glob
import os
import sys
from validate import validate_package

report_errors = []

for package in glob.glob("packages/*"):
  package_name = os.path.basename(package)

  print(f"Validating package: {package_name}... ", end='', flush=True)

  error = validate_package(package)
  if not error:
    print("OK")
    continue

  print(f"Check: {error}")
  
  report_errors.append({
    "package": package_name,
    "error": error,
  })

print("Generating CI report...")

with open("validation_report.md", "w", encoding="utf-8") as f:
  f.write("## CI Quality Check 🤖🚨 \n\n")

  if len(report_errors) == 0:
    f.write("All checks passed ✅ Great job!\n\n")
    f.write("![Great Job](https://raw.githubusercontent.com/cocmd/hub/main/.github/scripts/validate/great-job-image.jpg)")
  else:
    f.write("Oh snap! Our robots detected some errors 🤖 We need to solve them before merging the package:\n\n")
    for package in report_errors:
      package_name = package["package"]
      package_error = package["error"]
      f.write(f"### Package: {package_name} ❌\n\n")
      
    f.write("After you fixed the problems, please create another commit and push it to re-run the checks 🚀")

if len(report_errors) == 0:
  print("All ok!")
else:
  print("Errors detected, please see attached report.")
  sys.exit(1) 