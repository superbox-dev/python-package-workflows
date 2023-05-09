#!/usr/bin/env python
import argparse
import json
from os import environ
from pathlib import Path
from typing import Any
from typing import Dict
from typing import List
from typing import Optional

import toml


class Parameters:
    def __init__(self, inputs_json: str):
        self.parameters: Dict[str, Any] = json.loads(Path(inputs_json).read_text())
        self.python_version = self.parameters.get("python-versions", ["3.11"])
        self.pyproject: Dict[str, Any] = self.read_pyproject_toml()

    def get_python_version(self):
        return self.python_version

    def get_latest_python_version(self):
        return self.python_version[-1]

    @staticmethod
    def is_dev_version() -> bool:
        return environ["GITHUB_REF_TYPE"] != "tag"

    @staticmethod
    def read_pyproject_toml() -> Dict[str, Any]:
        content: str = Path("pyproject.toml").read_text()
        return toml.loads(content)

    def get_scripts(self) -> List[str]:
        _scripts: List[str] = []
        scripts: Optional[Dict[str, Any]] = self.pyproject["project"].get("scripts")

        if scripts:
            _scripts = list(scripts.keys())

        return _scripts

    def get_package_name(self) -> str:
        return self.pyproject["project"]["name"]

    def get_package_version(self) -> str:
        version_file: Path = Path(f"src/{self.get_package_name().replace('-', '_')}/version.txt")
        version: str = version_file.read_text(encoding="utf-8").replace("\n", "")

        if self.is_dev_version():
            version += f".dev{environ['GITHUB_RUN_NUMBER']}"

        return version


def main(args: argparse.Namespace) -> None:
    parameters = Parameters(
        inputs_json=args.INPUTS_JSON,
    )

    github_output: Path = Path(environ["GITHUB_OUTPUT"])

    with github_output.open("a", encoding="utf-8") as gho:
        gho.write(
            f"python-versions={parameters.get_python_version()!s}\n"
            f"latest-python-version={parameters.get_latest_python_version()!s}\n"
            f"package-name={parameters.get_package_name()!s}\n"
            f"package-version={parameters.get_package_version()!s}\n"
            f"binary-files={parameters.get_scripts()!s}\n"
            f"version-dev={parameters.is_dev_version()!s}\n"
        )

    print(github_output.read_text())


if __name__ == "__main__":
    parser: argparse.ArgumentParser = argparse.ArgumentParser()
    parser.add_argument("INPUTS_JSON")
    main(args=parser.parse_args())
