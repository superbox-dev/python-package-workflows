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

    def get_package_maintainer(self) -> str:
        maintainers: list[dict[str, str]] = self.pyproject["project"]["maintainers"]
        return f"{maintainers[0]['name']} <{maintainers[0]['email']}>"

    def get_package_source_url(self) -> str:
        source_url: str = self.pyproject["project"]["urls"]["Source code"]
        return source_url

    def get_package_description(self) -> str:
        description: str = self.pyproject["project"]["description"]
        return description

    def get_package_license(self) -> str:
        license: dict = self.pyproject["project"]["license"]
        return license["text"]

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
            f"package-maintainer={parameters.get_package_maintainer()!s}\n"
            f"package-source-url={parameters.get_package_source_url()!s}\n"
            f"package-description={parameters.get_package_description()!s}\n"
            f"package-license={parameters.get_package_license()!s}\n"
            f"binary-files={parameters.get_scripts()!s}\n"
            f"is-dev-version={parameters.is_dev_version()!s}\n"
        )

    print(github_output.read_text())


if __name__ == "__main__":
    parser: argparse.ArgumentParser = argparse.ArgumentParser()
    parser.add_argument("INPUTS_JSON")
    main(args=parser.parse_args())
