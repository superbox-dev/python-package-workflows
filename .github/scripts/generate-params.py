#!/usr/bin/env python
import argparse
import subprocess
import re
import json

from configparser import ConfigParser
from os import environ
from pathlib import Path
from typing import Any
from typing import Dict
from typing import List


def main(args: argparse.Namespace) -> None:
    parameters: Dict[str, Any] = json.loads(Path(args.INPUTS_JSON).read_text())
    python_versions: List[str] = parameters.get("python-versions", ["3.11"])
    binary_files: List[str] = []

    cf: ConfigParser = ConfigParser()
    cf.read("setup.cfg")

    if "options.entry_points" in cf.sections():
        for item in cf["options.entry_points"]["console_scripts"].split("\n"):
            if item:
                binary_files.append(item.split("=")[0].strip())

    latest_python_version: str = python_versions[-1]
    version_dev: bool = False

    if re.match(r"\d{4}\.\d{1,2}\.dev.*", args.GITHUB_REF_NAME):
        version_dev = True

    result_package_name: subprocess.CompletedProcess = subprocess.run(
        "python setup.py --name", shell=True, capture_output=True
    )
    package_name: str = result_package_name.stdout.decode().strip()

    result_package_version: subprocess.CompletedProcess = subprocess.run(
        "python setup.py --version", shell=True, capture_output=True
    )
    package_version: str = result_package_version.stdout.decode().strip()

    if version_dev:
        package_version += f".dev{args.GITHUB_RUN_NUMBER}"

    github_output: Path = Path(environ["GITHUB_OUTPUT"])

    with github_output.open("a", encoding="utf-8") as gho:
        gho.write(
            f"python-versions={python_versions!s}\n"
            f"latest-python-version={latest_python_version!s}\n"
            f"package-name={package_name!s}\n"
            f"package-version={package_version!s}\n"
            f"binary-files={binary_files!s}\n"
            f"version-dev={version_dev!s}\n"
        )

    print(github_output.read_text())


if __name__ == "__main__":
    parser: argparse.ArgumentParser = argparse.ArgumentParser()
    parser.add_argument("INPUTS_JSON")
    parser.add_argument("GITHUB_REF_NAME")
    parser.add_argument("GITHUB_RUN_NUMBER")
    args: argparse.Namespace = parser.parse_args()

    main(args)
