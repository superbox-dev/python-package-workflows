#!/usr/bin/env python
import argparse
import json
from importlib.metadata import metadata
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
        self.pyproject: Dict[str, Any] = self.read_pyproject_toml()

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
        version: str = self.pyproject["project"]["name"]
        return version

    @staticmethod
    def get_package_version(package_name: str) -> str:
        return metadata(package_name)["Version"]


def main(args: argparse.Namespace) -> None:
    parameters = Parameters(
        inputs_json=args.INPUTS_JSON,
    )

    github_output: Path = Path(environ["GITHUB_OUTPUT"])
    package_name: str = parameters.get_package_name()

    with github_output.open("a", encoding="utf-8") as gho:
        gho.write(
            f"package-name={package_name!s}\n"
            f"package-version={parameters.get_package_version(package_name)!s}\n"
            f"binary-files={parameters.get_scripts()!s}\n"
            f"is-dev-version={parameters.is_dev_version()!s}\n"
        )

    print(github_output.read_text())


if __name__ == "__main__":
    parser: argparse.ArgumentParser = argparse.ArgumentParser()
    parser.add_argument("INPUTS_JSON")
    main(args=parser.parse_args())
