# Templ Generic

[![HitCount](http://hits.dwyl.com/templ-project/generic.svg)](http://hits.dwyl.com/templ-project/generic)
[![Contributions welcome](https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat)](https://github.com/templ-project/generic/issues)

<!-- Donation Badges -->

[![Donate to this project using Patreon](https://img.shields.io/badge/patreon-donate-yellow.svg)](https://patreon.com/dragoscirjan)
[![Donate to this project using Paypal](https://img.shields.io/badge/paypal-donate-yellow.svg)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=QBP6DEBJDEMV2&source=url)

> _Any fool can write code that a computer can understand. Good programmers write code that humans can understand._ – Martin Fowler

> **generic** is a modern, cross-platform template for any project type.
>
> ## Features
>
> ### Build & Task Management
>
> - **[Taskfile](Taskfile.yml)** - Modern task runner with targets for building, testing, linting, and deployment
> - **[mise](https://mise.jdx.dev/)** - Development environment and tool version management
>
> ### Code Quality & Linting
>
> - **Shell Script Linting** - [ShellCheck](.scripts/lint-shellcheck.sh) integration with auto-fix support
> - **PowerShell Linting** - [PSScriptAnalyzer](.scripts/lint-powershell.ps1) with cross-platform support
> - **JSON/YAML/Markdown** - ESLint and Prettier integration
> - **Pre-commit Hooks** - Automated linting via [Husky](.husky/) and [lint-staged](.lintstagedrc.yml)
> - **Duplicate Code Detection** - jscpd integration with badge generation
>
> ### Git Integration
>
> - **GitHub Templates** - Issue and pull request templates in [.github](.github/)
> - **Pre-commit Validation** - Automatic code quality checks before commits
> - **Staged File Linting** - Only lint files you're committing
>
> ### Quick Start with UVX
>
> - **Bootstrap Script** - One-command project scaffolding via `uvx`
> - **Zero Configuration** - Automatic project name detection and setup
>
> ### Cross-Platform Support
>
> - Works on **Linux**, **macOS**, and **Windows** (including WSL)
> - Shell scripts compatible with bash/sh
> - PowerShell scripts compatible with PowerShell Core (pwsh)

## Getting Started

### Prereqiusites / Dependencies

##### For Windows

- Please install [git-scm](https://git-scm.com/download/win) tool.
- Please install a form of make
  - Install [Make for Windows](http://gnuwin32.sourceforge.net/packages/make.htm)
  - Install [make](https://sourceforge.net/projects/ezwinports/files/) from [ezwinports](https://sourceforge.net/projects/ezwinports/files/)
  - Install [chocolatey](https://chocolatey.org/), run `choco install make`

##### For Linux/Unix/OSX

- Please install `git` and `make`

```bash
# i.e debian
sudo apt-get install git make -y
# i.e mac OS
brew install make git
```

<!-- #### Known Issues / Troubleshooting

None for now. -->

### Installation

#### Quick Start with UVX (Recommended)

Bootstrap a new project with a single command using `uvx`:

```bash
# Bootstrap in current directory
uvx --from git+https://github.com/templ-project/generic.git bootstrap .

# Bootstrap in specific directory
uvx --from git+https://github.com/templ-project/generic.git bootstrap ./my-project

# Bootstrap with custom project name
uvx --from git+https://github.com/templ-project/generic.git bootstrap --project-name my-awesome-project ./target-dir
```

The bootstrap script will:

- Clone the template repository
- Remove template-specific files (.git, bootstrap scripts, etc.)
- Update project metadata (package.json, README.md)
- Set up your project structure

After bootstrapping:

```bash
cd your-project
git init
git add .
git commit -m "Initial commit"
```

#### Manual Installation

1. Clone the project
2. Remove .git folder
3. Re-initialize your git repository

```bash
git clone https://github.com/templ-project/generic your_project
cd your_project
rm -rf .git
git init
git add remote origin https://url/to/your/project/repository
git add .
git commit -am "init"
git push origin master
```

### Development

#### Prerequisites

- [mise](https://mise.jdx.dev/) - For tool version management
- [Task](https://taskfile.dev/) - Task runner (installed via mise)
- [Node.js](https://nodejs.org/) - For linting tools (installed via mise)
- [PowerShell Core](https://github.com/PowerShell/PowerShell) - For cross-platform scripting (installed via mise)

#### Setup Development Environment

```bash
# Install mise (if not already installed)
curl https://mise.run | sh

# Install all required tools
mise install

# Install Node.js dependencies
npm install

# Install pre-commit hooks
npx husky install
```

#### Available Tasks

```bash
# Code formatting
task format              # Format all code (prettier)
task format:check        # Check formatting without fixing

# Linting
task lint                # Lint all code (eslint, shellcheck, powershell)
task lint:shellcheck     # Lint shell scripts only
task lint:powershell     # Lint PowerShell scripts only
task lint:eslint         # Lint JSON/YAML/Markdown only

# Check mode (no auto-fix)
task lint:check          # Check all without fixing
task lint:check:shellcheck
task lint:check:powershell
task lint:check:eslint

# Code quality
task duplicate-check     # Check for duplicate code

# Full validation
task validate            # Run complete CI pipeline
```

#### Pre-commit Hooks

The template includes automatic pre-commit validation via Husky:

- **lint-staged** - Lints only staged files
- **shellcheck** - Validates shell scripts
- **powershell** - Validates PowerShell scripts
- **duplicate-check** - Detects code duplication

Configure what runs in [.lintstagedrc.yml](.lintstagedrc.yml) and [.husky/pre-commit](.husky/pre-commit).

### Testing

Adapt `test` directive in your Makefile to fit your needs.

### Deployment

Adapt `release` directive in your Makefile to fit your needs.

> `make release` will know how to increment version and create tags on its own.

## Authors

- [Dragos Cirjan](mailto:dragos.cirjan@gmail.com) - Initial work

## Issues / Support

Add a set of links to the [issues](/templ-project/generic/issues) page/website, so people can know where to add issues/bugs or ask for support.

## License

(If the package is public, add licence)
This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

<!-- ## Changelog

Small changelog history. The rest should be added to [CHANGELOG.md](CHANGELOG.md).

See here a template for changelogs: https://keepachangelog.com/en/1.0.0/

Also see this tool for automatically generating them: https://www.npmjs.com/package/changelog -->

> Remove Everything above this line

<hr />

# Project Title

<!-- Set of shield/badges explaining where to find more information about the project (i.e. Where to look for unit test reports, where to see code coverage and code scans, etc.). You can find a lot of them on https://shields.io/) -->

<!-- CI Badges -->

[![TravisCI](https://travis-ci.org/templ-project/generic.svg?branch=master)](https://travis-ci.org/templ-project/generic)

<!-- [![CircleCI](https://circleci.com/gh/templ-project/generic.svg?style=shield)](https://circleci.com/gh/templ-project/generic) -->

<!-- Sonar Badges -->
<!-- [![Sonarcloud Status](https://sonarcloud.io/api/project_badges/measure?project=templ-project_generic&metric=alert_status)](https://sonarcloud.io/dashboard?id=templ-project_generic)
[![SonarCloud Coverage](https://sonarcloud.io/api/project_badges/measure?project=templ-project_generic&metric=coverage)](https://sonarcloud.io/component_measures/metric/coverage/list?id=templ-project_generic)
[![SonarCloud Bugs](https://sonarcloud.io/api/project_badges/measure?project=templ-project_generic&metric=bugs)](https://sonarcloud.io/component_measures/metric/reliability_rating/list?id=templ-project_generic)
[![SonarCloud Vulnerabilities](https://sonarcloud.io/api/project_badges/measure?project=templ-project_generic&metric=vulnerabilities)](https://sonarcloud.io/component_measures/metric/security_rating/list?id=templ-project_generic) -->

<!-- Donation Badges -->
<!-- [![Donate to this project using Patreon](https://img.shields.io/badge/patreon-donate-yellow.svg)](https://patreon.com/dragoscirjan)
[![Donate to this project using Paypal](https://img.shields.io/badge/paypal-donate-yellow.svg)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=UMMN8JPLVAUR4&source=url)
[![Donate to this project using Flattr](https://img.shields.io/badge/flattr-donate-yellow.svg)](https://flattr.com/profile/balupton)
[![Donate to this project using Liberapay](https://img.shields.io/badge/liberapay-donate-yellow.svg)](https://liberapay.com/dragoscirjan)
[![Donate to this project using Thanks App](https://img.shields.io/badge/thanksapp-donate-yellow.svg)](https://givethanks.app/donate/npm/badges)
[![Donate to this project using Boost Lab](https://img.shields.io/badge/boostlab-donate-yellow.svg)](https://boost-lab.app/dragoscirjan/badges)
[![Donate to this project using Buy Me A Coffee](https://img.shields.io/badge/buy%20me%20a%20coffee-donate-yellow.svg)](https://buymeacoffee.com/balupton)
[![Donate to this project using Open Collective](https://img.shields.io/badge/open%20collective-donate-yellow.svg)](https://opencollective.com/dragoscirjan)
[![Donate to this project using Cryptocurrency](https://img.shields.io/badge/crypto-donate-yellow.svg)](https://dragoscirjan.me/crypto)
[![Donate to this project using Paypal](https://img.shields.io/badge/paypal-donate-yellow.svg)](https://dragoscirjan.me/paypal)
[![Buy an item on our wishlist for us](https://img.shields.io/badge/wishlist-donate-yellow.svg)](https://dragoscirjan.me/wishlist)
-->

One Paragraph of project description goes here

<!--
Insert Table of Contents Here
This can be done using [AlanWalk.markdown-toc](https://marketplace.visualstudio.com/items?itemName=AlanWalk.markdown-toc) plugin,
which is also included in
[itmcdev.generic-extension-pack](https://marketplace.visualstudio.com/items?itemName=itmcdev.generic-extension-pack) extension pack.
-->
<!-- TOC -->

- [Templ Generic](#templ-generic)
  - [Getting Started](#getting-started)
    - [Prereqiusites / Dependencies](#prereqiusites--dependencies)
      - [For Windows](#for-windows)
      - [For Linux/Unix/OSX](#for-linuxunixosx)
    - [Installation](#installation)
      - [Quick Start with UVX (Recommended)](#quick-start-with-uvx-recommended)
      - [Manual Installation](#manual-installation)
    - [Development](#development)
      - [Prerequisites](#prerequisites)
      - [Setup Development Environment](#setup-development-environment)
      - [Available Tasks](#available-tasks)
      - [Pre-commit Hooks](#pre-commit-hooks)
    - [Testing](#testing)
    - [Deployment](#deployment)
  - [Authors](#authors)
  - [Issues / Support](#issues--support)
  - [License](#license)
- [Project Title](#project-title)
  - [Getting Started](#getting-started-1)
    - [Prereqiusites / Dependencies](#prereqiusites--dependencies-1)
      - [For Windows](#for-windows-1)
      - [For Linux](#for-linux)
      - [Known Issues / Troubleshooting](#known-issues--troubleshooting)
    - [Installation](#installation-1)
      - [Say what the step will be](#say-what-the-step-will-be)
      - [And repeat](#and-repeat)
    - [Development](#development-1)
    - [Testing](#testing-1)
      - [Break down into (at least) unit tests](#break-down-into-at-least-unit-tests)
      - [and end to end tests](#and-end-to-end-tests)
      - [And coding style tests](#and-coding-style-tests)
    - [Deployment](#deployment-1)
  - [Authors](#authors-1)
  - [Issues / Support](#issues--support-1)
  - [License](#license-1)
  - [Changelog](#changelog)

<!-- /TOC -->

## Getting Started

### Prereqiusites / Dependencies

What things you need to install the software and how to install them (based on each OS type).

#### For Windows

```bash
# Give Examples

npm install -g node-gyp windows-build-tools
# Warning: Please note windows-build-tools will install MSVS which takes a
# LONG amount of time.
```

#### For Linux

```bash
# Give Examples

apt-get install build-essential mono
npm install -y node-gyp
```

#### Known Issues / Troubleshooting

Describe a list of known issues, and how to bypass them.

### Installation

A step by step series of examples that tell you how to get a development env running

#### Say what the step will be

```
Give the example
```

#### And repeat

```
until finished
```

End with an example of getting some data out of the system or using it for a little demo

### Development

Explain any development process for the project, if necesary

```
give examples
```

### Testing

Explain how to run the automated tests for this system

#### Break down into (at least) unit tests

Explain what these tests test and why

```
Give an example
```

#### and end to end tests

Explain what these tests test and why

```
Give an example
```

#### And coding style tests

Explain what these tests test and why

```
Give an example
```

### Deployment

Add additional notes about how to deploy this on a live system

## Authors

- [Dragos Cirjan](mailto:dragos.cirjan@gmail.com) - Initial work - [PurpleBooth](#link-to-change)

See also the list of contributors who participated in this project.

## Issues / Support

Add a set of links to the [issues](/templ-project/generic/issues) page/website, so people can know where to add issues/bugs or ask for support.

## License

(If the package is public, add licence)
This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Changelog

Small changelog history. The rest should be added to [CHANGELOG.md](CHANGELOG.md).

See here a template for changelogs: https://keepachangelog.com/en/1.0.0/

Also see this tool for automatically generating them: https://www.npmjs.com/package/changelog
