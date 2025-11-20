#!/usr/bin/env pwsh
# Lint shell scripts using ShellCheck
#
# Usage:
#   lint-shellcheck.ps1 [-Fix] [-Staged]
#
# Options:
#   -Fix     Apply fixes automatically (using git apply)
#   -Staged  Only lint files staged in git
#
# Exit codes:
#   0 - Success (no issues or all fixed)
#   1 - Issues found (in check mode)
#   2 - ShellCheck not installed

[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'Fix')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'Staged')]
param(
  [switch]$Fix,
  [switch]$Staged,
  [switch]$Help
)

$ErrorActionPreference = 'Stop'

# ============================================================================
# Configuration
# ============================================================================

# Colors
class Colors {
  static [string] $Reset = "`e[0m"
  static [string] $Red = "`e[31m"
  static [string] $Green = "`e[32m"
  static [string] $Yellow = "`e[33m"
  static [string] $Gray = "`e[90m"
  static [string] $White = "`e[37m"
  static [string] $Cyan = "`e[36m"
}

# Folders to exclude from linting
$IGNORED_FOLDERS = @(
  'node_modules',
  '.husky',
  '.git',
  'vendor',
  'target',
  'dist',
  'build'
)

# ============================================================================

# Show help if requested
if ($Help) {
  Write-Host 'Usage: lint-shellcheck.ps1 [-Fix] [-Staged]'
  Write-Host ''
  Write-Host 'Options:'
  Write-Host '  -Fix     Apply fixes automatically'
  Write-Host '  -Staged  Only lint staged git files'
  Write-Host '  -Help    Show this help message'
  exit 0
}

# Check if shellcheck is installed
if (-not (Get-Command shellcheck -ErrorAction SilentlyContinue)) {
  Write-Host "$([Colors]::Red)✗ ShellCheck is not installed$([Colors]::Reset)"
  Write-Host 'Install it: https://github.com/koalaman/shellcheck#installing'
  exit 2
}

# Get list of shell scripts
function Get-ShellScript {
  $repoRoot = (Get-Location).Path

  if ($Staged) {
    # Only get staged .sh files
    $stagedFiles = git diff --cached --name-only --diff-filter=ACM | Where-Object { $_ -match '\.sh$' }
    return $stagedFiles | ForEach-Object {
      Join-Path $repoRoot $_
    }
  }
  else {
    # Find all .sh files excluding common directories
    Get-ChildItem -Path $repoRoot -Filter '*.sh' -Recurse -File | Where-Object {
      $path = $_.FullName
      $excluded = $false
      foreach ($dir in $IGNORED_FOLDERS) {
        if ($path -like "*\$dir\*") {
          $excluded = $true
          break
        }
      }
      -not $excluded
    } | Select-Object -ExpandProperty FullName
  }
}

# Main linting logic
function Invoke-Linting {
  $files = @(Get-ShellScript)

  if ($files.Count -eq 0) {
    Write-Host "$([Colors]::Yellow)No shell scripts found to lint$([Colors]::Reset)"
    exit 0
  }

  $hasIssues = $false
  $fileCount = 0

  Write-Host 'ShellCheck: Linting shell scripts...'
  Write-Host ''

  foreach ($file in $files) {
    if (-not $file) { continue }

    $fileCount++
    $relativePath = if ($file.StartsWith((Get-Location).Path)) {
      $file.Substring((Get-Location).Path.Length).TrimStart('\', '/')
    }
    else {
      $file
    }

    if ($Fix) {
      # Apply fixes using shellcheck diff output
      $diffOutput = shellcheck -x --severity=style --format=diff $file 2>&1

      if ($LASTEXITCODE -ne 0 -and $diffOutput) {
        $diffOutput | git apply --allow-empty 2>&1 | Out-Null
        Write-Host "$([Colors]::White)  Fixed: $relativePath$([Colors]::Reset)"
      }

      # Check for remaining issues
      $ttyOutput = shellcheck -x --severity=style --format=tty $file 2>&1

      if ($LASTEXITCODE -ne 0 -and $ttyOutput) {
        $hasIssues = $true
        Write-Host "$([Colors]::White)$relativePath$([Colors]::Reset)"
        Write-Host $ttyOutput
      }
      else {
        Write-Host "$([Colors]::Gray)  OK: $relativePath$([Colors]::Reset)"
      }
    }
    else {
      # Check-only mode
      $ttyOutput = shellcheck -x --severity=style --format=tty $file 2>&1

      if ($LASTEXITCODE -ne 0 -and $ttyOutput) {
        $hasIssues = $true
        Write-Host "$([Colors]::White)$relativePath$([Colors]::Reset)"
        Write-Host $ttyOutput
        Write-Host ''
      }
      else {
        Write-Host "$([Colors]::Gray)  OK: $relativePath$([Colors]::Reset)"
      }
    }
  }

  Write-Host ''
  Write-Host "Checked $fileCount shell script(s)"

  if ($hasIssues) {
    if ($Fix) {
      Write-Host ""
      Write-Host "$([Colors]::Yellow)⚠ Some issues could not be auto-fixed$([Colors]::Reset)"
      Write-Host 'Please review and fix them manually'
      exit 1
    }
    else {
      Write-Host "$([Colors]::Red)✗ ShellCheck found issues$([Colors]::Reset)"
      Write-Host 'Run with -Fix to apply automatic fixes: .\lint-shellcheck.ps1 -Fix'
      exit 1
    }
  }
  else {
    Write-Host "$([Colors]::Green)✓ All shell scripts are clean$([Colors]::Reset)"
    exit 0
  }
}

Invoke-Linting
