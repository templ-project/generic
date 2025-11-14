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
  Write-Host "$([Colors]::Yellow)Installing PSScriptAnalyzer...$([Colors]::Reset)"
  try {
    Install-Module -Name PSScriptAnalyzer -Force -Scope CurrentUser -SkipPublisherCheck -ErrorAction Stop
    Write-Host "$([Colors]::Green)✓ PSScriptAnalyzer installed successfully$([Colors]::Reset)"
  }
  catch {
    Write-Host "$([Colors]::Red)✗ Failed to install PSScriptAnalyzer: $_$([Colors]::Reset)"
    exit 2
  }
}

# Get list of PowerShell scripts
function Get-PowerShellScript {
  # Use current working directory as the repository root
  # The task system ensures we're running from the repo root
  $repoRoot = Get-Location

  if ($Staged) {
    # Get only staged .ps1 files
    $stagedFiles = git diff --cached --name-only --diff-filter=ACM | Where-Object { $_ -match '\.ps1$' }
    return $stagedFiles | ForEach-Object {
      $filePath = Join-Path $repoRoot $_
      if (Test-Path $filePath) {
        Get-Item $filePath
      }
    }
  }
  else {
    # Get all .ps1 files excluding ignored directories
    # Use a custom recursive function for better performance - it skips excluded dirs entirely
    $results = [System.Collections.ArrayList]::new()

    function Get-PowerShellScriptsRecursive {
      param([string]$path, [System.Collections.ArrayList]$resultList)

      try {
        # Get all items in current directory (non-recursive)
        $items = Get-ChildItem -Path $path -Force -ErrorAction SilentlyContinue

        foreach ($item in $items) {
          # Skip if folder name is in ignored list
          if ($item.PSIsContainer -and $IGNORED_FOLDERS -contains $item.Name) {
            continue
          }

          # If it's a .ps1 file, add it
          if (-not $item.PSIsContainer -and $item.Extension -eq '.ps1') {
            [void]$resultList.Add($item)
          }

          # If it's a directory (and not ignored), recurse into it
          if ($item.PSIsContainer) {
            Get-PowerShellScriptsRecursive -path $item.FullName -resultList $resultList
          }
        }
      }
      catch {
        # Silently skip directories we can't access (permission denied, etc.)
        Write-Verbose "Skipping inaccessible path: $path - $_"
      }
    }

    Get-PowerShellScriptsRecursive -path $repoRoot -resultList $results
    return $results.ToArray()
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
    Write-Host "$([Colors]::Yellow)No PowerShell scripts found to lint$([Colors]::Reset)"
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
          Write-Host "$([Colors]::White)  Fixed: $($script.Name)$([Colors]::Reset)"
        }
      }
      catch {
        Write-Host "$([Colors]::Yellow)  Warning: Could not apply fixes to $($script.Name)$([Colors]::Reset)"
      }

      # Check for remaining issues
      $params.Remove('Fix')
      $issues = Invoke-ScriptAnalyzer @params -ErrorAction SilentlyContinue

      if ($issues) {
        $hasIssues = $true
        Write-Host "$([Colors]::White)$($script.Name)$([Colors]::Reset)"
        $issues | Format-Table -Property Line, Severity, RuleName, Message -AutoSize | Out-String | Write-Host
      }
      else {
        Write-Host "$([Colors]::Gray)  OK: $($script.Name)$([Colors]::Reset)"
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
        Write-Host "$([Colors]::White)$($script.Name)$([Colors]::Reset)"
        $issues | Format-Table -Property Line, Severity, RuleName, Message -AutoSize | Out-String | Write-Host
        Write-Host ""
      }
      else {
        Write-Host "$([Colors]::Gray)  OK: $($script.Name)$([Colors]::Reset)"
      }
    }
  }

  Write-Host ""
  Write-Host "Checked $fileCount PowerShell script(s)"

  if ($hasIssues) {
    if ($Fix) {
      Write-Host ""
      Write-Host "$([Colors]::Yellow)⚠ Some issues could not be auto-fixed$([Colors]::Reset)"
      Write-Host "Please review and fix them manually"
      exit 1
    }
    else {
      Write-Host "$([Colors]::Red)✗ PSScriptAnalyzer found issues$([Colors]::Reset)"
      Write-Host "Run with -Fix to apply automatic fixes: .\lint-powershell.ps1 -Fix"
      exit 1
    }
  }
  else {
    Write-Host "$([Colors]::Green)✓ All PowerShell scripts are clean$([Colors]::Reset)"
    exit 0
  }
}

# Run main function
Invoke-LintPowerShell
