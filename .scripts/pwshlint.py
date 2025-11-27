#!/usr/bin/env python3
import sys
import os
import subprocess
import shutil

# Add the current directory to sys.path to allow importing pylib
script_dir = os.path.dirname(os.path.abspath(__file__))
sys.path.append(script_dir)

from pylib.linter import Linter, Colors

class PwshLinter(Linter):
    def __init__(self):
        super().__init__("PSScriptAnalyzer", "**/*.ps1")

    def check_installed(self):
        if not shutil.which("pwsh"):
            print(f"{Colors.RED}[FAIL] PowerShell (pwsh) is not installed{Colors.RESET}")
            sys.exit(2)

        # Check for PSScriptAnalyzer module
        check_cmd = "Get-Module -ListAvailable -Name PSScriptAnalyzer"
        result = subprocess.run(["pwsh", "-Command", check_cmd], capture_output=True, text=True)

        if result.returncode != 0 or not result.stdout.strip():
            print(f"{Colors.YELLOW}Installing PSScriptAnalyzer...{Colors.RESET}")
            install_cmd = "Install-Module -Name PSScriptAnalyzer -Force -Scope CurrentUser -SkipPublisherCheck -ErrorAction Stop"
            install_res = subprocess.run(["pwsh", "-Command", install_cmd], capture_output=True, text=True)
            if install_res.returncode != 0:
                print(f"{Colors.RED}[FAIL] Failed to install PSScriptAnalyzer: {install_res.stderr}{Colors.RESET}")
                sys.exit(2)
            print(f"{Colors.GREEN}[OK] PSScriptAnalyzer installed successfully{Colors.RESET}")

    def lint_file(self, file_path: str, fix: bool) -> bool:
        # We need to construct the PowerShell command
        # Using -Settings if .PSScriptAnalyzerSettings.psd1 exists in parent of script dir?
        # The original script looked for settings file relative to itself.
        # script_dir is .scripts/
        # settings file is .PSScriptAnalyzerSettings.psd1 in root (parent of .scripts)

        root_dir = os.path.dirname(script_dir)
        settings_file = os.path.join(root_dir, ".PSScriptAnalyzerSettings.psd1")
        settings_arg = ""
        if os.path.exists(settings_file):
            settings_arg = f"-Settings '{settings_file}'"

        if fix:
            # Try to fix
            cmd = f"Invoke-ScriptAnalyzer -Path '{file_path}' -Fix {settings_arg} -ErrorAction SilentlyContinue"

            try:
                subprocess.run(["pwsh", "-Command", cmd], capture_output=True, text=True)
                # We assume it ran. We don't have easy diff output like shellcheck.
            except Exception as e:
                 print(f"{Colors.YELLOW}  Warning: Error during fix for {file_path}: {e}{Colors.RESET}")

        # Check for issues
        cmd = f"Invoke-ScriptAnalyzer -Path '{file_path}' {settings_arg} -ErrorAction SilentlyContinue | Format-Table -Property Line, Severity, RuleName, Message -AutoSize | Out-String -Width 4096"

        result = subprocess.run(["pwsh", "-Command", cmd], capture_output=True, text=True)

        output = result.stdout.strip()
        if result.returncode == 0 and output:
            # If there is output, there are issues
            print(f"{Colors.WHITE}{file_path}{Colors.RESET}")
            print(output)
            return True
        else:
            print(f"{Colors.GRAY}  OK: {file_path}{Colors.RESET}")
            return False

if __name__ == "__main__":
    PwshLinter().run()
