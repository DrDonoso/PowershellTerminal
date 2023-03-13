# My powershell terminal

A brief description on how to install my custom powershell terminal.

## Installation

Clone this repository to start with the installation.

### Execution Policy

Maybe there will be some problems with the executions policies, to solve it run:

```ps1
Set-ExecutionPolicy Unrestricted
```

### Install font

It is required to have a nerd font to use all the icons. Here, I am using **Caskaydia Font**. To install it, open the files and click install as shown in the image:

![Install-Fonts](assets/Install-Caskaydia-Font.png)

Then, on windows terminal, update your Powershell profile to use this font:

![Terminal-Font](assets/Terminal-Font.png)

### Install Terminal-Icons

This module displays directory listing color and icons.

```ps1
Install-Module -Name Terminal-Icons -Repository PSGallery
```

### Install PSReadLine

We will need PSReadLine for autocompletion and predictive IntelliSense.
Install it with:

```ps1
Install-Module PSReadLine -Force
```

### Install PSFzf

[PSFzf](https://github.com/kelleyma49/PSFzf) is a [fzf](https://github.com/junegunn/fzf) wrapper.

First, install fzf with chocolatey or scoop:

```ps1
choco install fzf
```

And then, install PSFzf:

```ps1
Install-Module PSFzf
```

### Install gawk

```ps1
choco install gawk
```

### Install oh-my-posh

We need [oh-my-posh](https://ohmyposh.dev/).

```ps1
winget install JanDeDobbeleer.OhMyPosh
```

Then, run the **install.ps1** script to create the profile and add the oh-my-posh prompt and add the alias.
Reload the terminal to reload $PATH and apply changes.
