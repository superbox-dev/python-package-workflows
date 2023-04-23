import subprocess
import re

from os import environ
from pathlib import Path

python_version = "${{ inputs.python-version }}".split(" ")
latest_python_version = python_version[-1]
version_dev = False

if re.match(r"\d{4}\.\d{1,2}\.dev.*", "${{ github.ref_name }}"):
    version_dev = True

result_package_name = subprocess.run("python setup.py --name", shell=True, capture_output=True)
package_name = result_package_name.stdout.decode().strip()

result_package_version = subprocess.run("python setup.py --version", shell=True, capture_output=True)
package_version = result_package_version.stdout.decode().strip()

if version_dev:
    package_version += ".dev${{ github.run_number }}"

with open(environ["GITHUB_OUTPUT"], "a", encoding="utf-8") as gho:
    gho.write(
        f"python-version={python_version!s}\n"
        f"latest-python-version={latest_python_version!s}\n"
        f"package-name={package_name!s}\n"
        f"package-version={package_version!s}\n"
    )

print(Path(environ["GITHUB_OUTPUT"]).read_text())
