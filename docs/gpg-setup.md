# Signing commits with GPG

How to create a GPG key, add it to GitHub, and configure Git to sign your commits.

> GnuPG is already installed by `tools/winget.ps1` (`GnuPG.GnuPG`). If you don't
> have it, install it first with `winget install --id GnuPG.GnuPG`.

## 1. Generate a key

```ps1
gpg --full-generate-key
```

Choose `RSA and RSA`, `4096` bits, an expiration that suits you, and enter the
same name and email you use on GitHub.

## 2. Find the key id

```ps1
gpg --list-secret-keys --keyid-format=long
```

Look at the `sec` line and copy the short key id (the part after `rsa4096/`):

```text
sec   rsa4096/[short-key] 2021-06-14 [SC]
```

## 3. Export the public key

```ps1
gpg --armor --export [short-key]
```

This prints the full ASCII-armored public key:

```text
-----BEGIN PGP PUBLIC KEY BLOCK-----
[huge-ascii-key]
-----END PGP PUBLIC KEY BLOCK-----
```

## 4. Add the key to GitHub

Copy the whole block (including the `BEGIN`/`END` lines) and add it to your
account:

**Profile > Settings > SSH and GPG keys > New GPG key**

## 5. Configure Git to sign commits

Run these inside the repository you want to sign (drop `--global` to keep it
local to that repo, add it to sign every repo on your machine):

```ps1
git config user.signingkey [short-key]
git config commit.gpgsign true
git config gpg.program "C:/Program Files (x86)/gnupg/bin/gpg"
```

> The `gpg.program` path is where winget's GnuPG installs the executable. If you
> installed it elsewhere, point it to your own `gpg.exe` (check with
> `(Get-Command gpg).Source`).

From now on your commits are signed and show up as **Verified** on GitHub.
