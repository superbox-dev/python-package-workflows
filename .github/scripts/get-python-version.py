#!/usr/bin/env python
import argparse
import json
from os import environ
from pathlib import Path
from typing import Any
from typing import Dict


class PythonVersion:
    def __init__(self, inputs_json: str):
        self.parameters: Dict[str, Any] = json.loads(Path(inputs_json).read_text())
        self.python_version: list[str] = self.parameters.get("python-versions", ["3.11"])

    def get_python_version(self) -> list[str]:
        return self.python_version

    def get_latest_python_version(self) -> str:
        return self.python_version[-1]


def main(args: argparse.Namespace) -> None:
    parameters: PythonVersion = PythonVersion(
        inputs_json=args.INPUTS_JSON,
    )

    github_output: Path = Path(environ["GITHUB_OUTPUT"])

    with github_output.open("a", encoding="utf-8") as gho:
        gho.write(
            f"python-versions={parameters.get_python_version()!s}\n"
            f"latest-python-version={parameters.get_latest_python_version()!s}\n"
        )

    print(github_output.read_text())


if __name__ == "__main__":
    parser: argparse.ArgumentParser = argparse.ArgumentParser()
    parser.add_argument("INPUTS_JSON")
    main(args=parser.parse_args())
