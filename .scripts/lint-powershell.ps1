#!/usr/bin/env pwsh
# Lint PowerShell scripts using PSScriptAnalyzer
#
# Usage:
#   lint-powershell.ps1 [-Fix] [-Staged]
#
# Options:
#   -Fix     Apply fixes automatically
#   -Staged  Only lint files staged in git
#
# Exit codes:
#   0 - Success (no issues or all fixed)
#   1 - Issues found (in check mode)
#   2 - PSScriptAnalyzer not installed

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

# Folders to exclude from linting
$IGNORED_FOLDERS = @(
  'node_modules',
  '.venv',
  'venv',
  '.git',
  'vendor',
  'target',
  'dist',
  'build'
)

# ============================================================================

# Show help
if ($Help) {
  Write-Host "Usage: lint-powershell.ps1 [-Fix] [-Staged]"
  Write-Host ""
  Write-Host "Options:"
  Write-Host "  -Fix     Apply fixes automatically"
  Write-Host "  -Staged  Only lint staged git files"
  Write-Host "  -Help    Show this help message"
  exit 0
}

# Check if PSScriptAnalyzer is installed
function Test-PSScriptAnalyzerInstalled {
  $module = Get-Module -ListAvailable -Name PSScriptAnalyzer
  return $null -ne $module
}

# Install PSScriptAnalyzer if missing
function Install-PSScriptAnalyzerModule {
  Write-Host "Installing PSScriptAnalyzer..." -ForegroundColor Yellow
  try {
    Install-Module -Name PSScriptAnalyzer -Force -Scope CurrentUser -SkipPublisherCheck -ErrorAction Stop
    Write-Host "✓ PSScriptAnalyzer installed successfully" -ForegroundColor Green
  }
  catch {
    Write-Host "✗ Failed to install PSScriptAnalyzer: $_" -ForegroundColor Red
    exit 2
  }
}

# Get list of PowerShell scripts
function Get-PowerShellScript {
  if ($Staged) {
    # Get only staged .ps1 files
    $stagedFiles = git diff --cached --name-only --diff-filter=ACM | Where-Object { $_ -match '\.ps1$' }
    return $stagedFiles | ForEach-Object { Get-Item $_ -ErrorAction SilentlyContinue }
  }
  else {
    # Get all .ps1 files excluding ignored directories
    $pattern = '[\\/](' + ($IGNORED_FOLDERS -join '|') + ')[\\/]'
    return Get-ChildItem -Recurse -Filter *.ps1 -File | Where-Object {
      $_.FullName -notmatch $pattern
    }
  }
}

# Main linting logic
function Invoke-LintPowerShell {
  # Ensure PSScriptAnalyzer is available
  if (-not (Test-PSScriptAnalyzerInstalled)) {
    Install-PSScriptAnalyzerModule
  }

  # Get settings file path
  $settingsFile = Join-Path -Path $PSScriptRoot -ChildPath ".." | Join-Path -ChildPath ".PSScriptAnalyzerSettings.psd1"
  if (-not (Test-Path -Path $settingsFile)) {
    $settingsFile = $null
  }

  # Get list of PowerShell scripts
  $scripts = Get-PowerShellScript

  if (-not $scripts -or $scripts.Count -eq 0) {
    Write-Host "No PowerShell scripts found to lint" -ForegroundColor Yellow
    exit 0
  }

  Write-Host "PSScriptAnalyzer: Linting PowerShell scripts..."
  Write-Host ""

  $hasIssues = $false
  $fileCount = 0

  foreach ($script in $scripts) {
    $fileCount++

    if ($Fix) {
      # Apply fixes
      $params = @{
        Path = $script.FullName
        Fix = $true
      }
      if ($settingsFile) {
        $params['Settings'] = $settingsFile
      }

      try {
        $fixes = Invoke-ScriptAnalyzer @params -ErrorAction SilentlyContinue

        if ($fixes) {
          Write-Host "  Fixed: $($script.FullName)" -ForegroundColor Cyan
          Write-Host "    Fixed $($fixes.Count) issue(s)" -ForegroundColor White
        }
      }
      catch {
        Write-Host "  Warning: Could not apply fixes to $($script.FullName)" -ForegroundColor Yellow
      }

      # Check for remaining issues
      $params.Remove('Fix')
      $issues = Invoke-ScriptAnalyzer @params -ErrorAction SilentlyContinue

      if ($issues) {
        $hasIssues = $true
        Write-Host "  Remaining issues in: $($script.FullName)" -ForegroundColor Yellow
        $issues | Format-Table -Property Line, Severity, RuleName, Message -AutoSize | Out-String | Write-Host
      }
      else {
        Write-Host "  OK: $($script.FullName)" -ForegroundColor Gray
      }
    }
    else {
      # Check-only mode
      $params = @{
        Path = $script.FullName
      }
      if ($settingsFile) {
        $params['Settings'] = $settingsFile
      }

      $issues = Invoke-ScriptAnalyzer @params -ErrorAction SilentlyContinue

      if ($issues) {
        $hasIssues = $true
        Write-Host "$($script.FullName)" -ForegroundColor White
        $issues | Format-Table -Property Line, Severity, RuleName, Message -AutoSize | Out-String | Write-Host
        Write-Host ""
      }
      else {
        Write-Host "  OK: $($script.FullName)" -ForegroundColor Gray
      }
    }
  }

  Write-Host ""
  Write-Host "Checked $fileCount PowerShell script(s)"

  if ($hasIssues) {
    if ($Fix) {
      Write-Host ""
      Write-Host "⚠ Some issues could not be auto-fixed" -ForegroundColor Yellow
      Write-Host "Review the remaining issues above and fix them manually"
      exit 1
    }
    else {
      Write-Host "✗ PSScriptAnalyzer found issues" -ForegroundColor Red
      Write-Host "Run with -Fix to apply automatic fixes: .\lint-powershell.ps1 -Fix"
      exit 1
    }
  }
  else {
    Write-Host "✓ All PowerShell scripts are clean" -ForegroundColor Green
    exit 0
  }
}

# Run main function
Invoke-LintPowerShell
