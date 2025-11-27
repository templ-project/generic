#!/usr/bin/env python3
import sys
import os
import subprocess
import shutil

# Add the current directory to sys.path to allow importing pylib
script_dir = os.path.dirname(os.path.abspath(__file__))
sys.path.append(script_dir)

from pylib.linter import Linter, Colors

class ShellLinter(Linter):
    def __init__(self):
        super().__init__("ShellCheck", "**/*.sh")

    def check_installed(self):
        if not shutil.which("shellcheck"):
            print(f"{Colors.RED}[FAIL] ShellCheck is not installed{Colors.RESET}")
            print("Install it: https://github.com/koalaman/shellcheck#installing")
            sys.exit(2)

    def lint_file(self, file_path: str, fix: bool) -> bool:
        if fix:
            try:
                result = subprocess.run(
                    ["shellcheck", "-x", "--severity=style", "--format=diff", file_path],
                    capture_output=True,
                    text=True
                )

                if result.stdout:
                    apply_process = subprocess.run(
                        ["git", "apply", "--allow-empty"],
                        input=result.stdout,
                        text=True,
                        capture_output=True
                    )

                    if apply_process.returncode == 0:
                        print(f"{Colors.WHITE}  Fixed: {file_path}{Colors.RESET}")
                    else:
                        print(f"{Colors.YELLOW}  Warning: Could not apply fixes to {file_path}{Colors.RESET}")
                        print(apply_process.stderr)

            except Exception as e:
                print(f"{Colors.YELLOW}  Warning: Error during fix for {file_path}: {e}{Colors.RESET}")

        result = subprocess.run(
            ["shellcheck", "-x", "--severity=style", "--format=tty", file_path],
            capture_output=True,
            text=True
        )

        if result.returncode != 0 and result.stdout.strip():
            print(f"{Colors.WHITE}{file_path}{Colors.RESET}")
            print(result.stdout)
            return True
        else:
            print(f"{Colors.GRAY}  OK: {file_path}{Colors.RESET}")
            return False

if __name__ == "__main__":
    ShellLinter().run()

