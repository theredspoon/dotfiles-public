# dotfiles-public

Portable workstation baseline configuration.

This repository contains curated, reproducible shell and Git configuration designed to be layered with an optional private overlay.  It is meant to sit in `~/.config/dotfiles-public` and never contain any secrets or host specific settings.

The public repo is your *baseline*; everything here is safe to commit to a public git server and share across machines.  Host‑ or user‑specific tweaks belong in a companion private repository (see below).

---

## Design Principles

* Reproducible environment
* Minimal `$HOME` clutter
* Explicit layering (public baseline + private overlay)
* No secrets in public configuration
* Idempotent setup

---

## Structure

```text
git/
  gitconfig.base
  gitconfig.aliases
  gitignore.global

bash/
  bash_profile.base
  bashrc.base

shell/
  profile.base

zsh/
  p10k/
    p10k.base.zsh
  zprofile.base
  zshrc.base

install.sh
```

The `git/` directory holds fragments that are `include`d into your
`~/.gitconfig`.  The `zsh/` tree contains snippets that are sourced by your
actual `~/.zshrc`/`~/.zprofile`.

---

Configuration is applied via `~/.gitconfig` includes rather than copying files directly into `$HOME`.

---

## Installation

If you plan to use a private overlay, create `~/.config/dotfiles-private` and
populate it (or at least make the directory) **before** running the installer.
The script will detect that directory and add the private gitconfig include
automatically.

Clone the public repository into `~/.config` (or anywhere you prefer) and run
the installer from its directory:

```bash
git clone git@github.com:theredspoon/dotfiles-public.git ~/.config/dotfiles-public
cd ~/.config/dotfiles-public
./install.sh
```

The installer does only one thing: it ensures the following lines exist in
your global `~/.gitconfig`:

```gitconfig
[include]
 path = ~/.config/dotfiles-public/git/gitconfig.base
[include]
 path = ~/.config/dotfiles-public/git/gitconfig.aliases
```

If a private overlay is present the script will also include
`~/.config/dotfiles-private/git/gitconfig.private`.

> **Note:** nothing in this repository is copied into your home directory;
> configuration is layered via `git` includes.  You are free to symlink or
> source the shell fragments yourself (see “Shell setup” below).
>
> **Order of operations:** the installer only writes to `~/.gitconfig`.  You
> should set up any shell startup files (or symlinks) and the optional private
> overlay *before* you start a new login shell; this is usually a one‑time
> manual step per host.

### Shell setup

The public `zsh` files are written to be sourced from your real
`~/.zshrc`/`~/.zprofile`.  For example, your home `~/.zshrc` might look like:

```zsh
# source the public baseline; it will also pull in your private overlay
# automatically if one exists, so you don’t need to duplicate that check here.
source "$HOME/.config/dotfiles-public/zsh/zshrc.base"
```

(The `zshrc.base` file defines helpers such as `source_if_exists` and
handles the private overlay itself.)  Bash users can follow the same pattern
in `~/.bashrc`/`~/.bash_profile`:

```bash
source "$HOME/.config/dotfiles-public/bash/bashrc.base"
```

If you prefer to keep a tiny home‑directory file, you can symlink instead:

```bash
ln -s "$HOME/.config/dotfiles-public/zsh/zshrc.base" ~/.zshrc
```

---

## Optional Private Overlay

For anything that is *not* suitable for public consumption—API keys, host
customizations, Wi‑Fi passwords, or just machine‑specific tweaks—put it in a
parallel directory:

```text
~/.config/dotfiles-private/
```

If you create the directory manually, the following skeleton is a sensible
starting point:

```text
~/.config/dotfiles-private/
├── git/
│   └── gitconfig.private          # extra `git` includes or overrides
├── zsh/
│   └── zshrc.private              # machine-specific shell additions
├── bash/
│   └── bashrc.private
└── shell/
    └── profile.private            # other shells or environment settings
```

You don’t need to populate every subdirectory; only create the ones you
actually use.  Private profile files for zsh and bash are almost certainly not needed.  The public files already know how to source each `*.private` counterpart if it exists—no extra wiring is required.

Structure the private repo the same way as the public one: you may have a
`git/gitconfig.private` to hold private git settings, a `zsh/zshrc.private`
for shell customisations, etc.  The installer will automatically add an
`include` for `gitconfig.private` if that file exists.  Your shell start‑up
files in the public repo already source the corresponding private pieces if
present.

> The private repository is managed by you (and may itself be git‑ignored or
> stored in a different host).  Nothing in the public repo depends on it, and
> you may delete the private directory entirely without breaking the public
> configuration.
