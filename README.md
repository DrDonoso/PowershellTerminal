# My powershell terminal

A brief description on how to install my custom powershell terminal.

## Installation

You can either clone this repository, or run the bootstrap script directly from GitHub without cloning.

### Quick install (no clone)

Run this one-liner in PowerShell. It downloads the repository to a temporary folder, installs the base tools with winget (`tools/winget.ps1`), the PowerShell modules (`tools/ps.ps1`), the Chocolatey packages (`tools/choco.ps1`) and some extra tools (`tools/others.ps1`), runs `install.ps1`, and removes the temporary files afterwards:

```ps1
irm https://raw.githubusercontent.com/DrDonoso/PowershellTerminal/main/bootstrap.ps1 | iex
```

The scripts install all the required tools, PowerShell modules and Chocolatey packages, install the Caskaydia Nerd Font, apply the Windows Terminal `settings.json`, and create the PowerShell profile with the oh-my-posh prompt and the aliases.

### Execution Policy

Maybe there will be some problems with the executions policies, to solve it run:

```ps1
Set-ExecutionPolicy Unrestricted
```

## Windows Terminal settings

The Windows Terminal configuration is kept in [`terminal/settings.json`](terminal/settings.json).
`install.ps1` applies it automatically, backing up the current one to
`settings.backup-<timestamp>.json` next to it first.

After tweaking Windows Terminal from the UI, capture your changes back into the repo and commit
them:

```ps1
pwsh -File terminal\export-settings.ps1
```

> The `backgroundImage` in the profile defaults is an absolute path to the Pokemon-Terminal image
> (set by `tools/others.ps1` running `pokemon mew`), so it is machine-specific.

## Sign commits with GPG

See [docs/gpg-setup.md](docs/gpg-setup.md) for how to create a GPG key, add it to
GitHub, and configure Git to sign your commits.
