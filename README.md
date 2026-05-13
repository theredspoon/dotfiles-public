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

## Prerequisites

The configuration degrades gracefully — each layer is optional:

| Layer | Required for |
| --- | --- |
| `zsh` | Everything zsh-related |
| [Oh My Zsh](https://ohmyz.sh) | Plugin management and the OMZ plugin set |
| [`zsh-autosuggestions`](https://github.com/zsh-users/zsh-autosuggestions) | Fish-style inline suggestions |
| [`zsh-syntax-highlighting`](https://github.com/zsh-users/zsh-syntax-highlighting) | Command syntax colouring |
| [Powerlevel10k](https://github.com/romkatv/powerlevel10k) | Zsh prompt theme |
| [Starship](https://starship.rs) | Bash prompt theme |
| A [Nerd Font](https://www.nerdfonts.com) | Prompt icons (both Powerlevel10k and Starship) |

A full Nerd Font from nerdfonts.com is required for prompt icons in both Powerlevel10k (zsh) and Starship (bash).  MesloLGS NF — the minimal font that `p10k configure` can install automatically — does not include the broader glyph sets (Material Design, Font Awesome, etc.) that both prompt systems draw on.  Install a full Nerd Font and configure your terminal to use it before running either prompt.

The two third-party zsh plugins must be installed into `$ZSH_CUSTOM/plugins/` (see their READMEs).  If they are absent the shell still starts cleanly — `zshrc.base` checks for the plugin directories before enabling them.

No Powerlevel10k config file is included in this repo.  Run `p10k configure` after installation — the wizard generates a `~/.p10k.zsh` tuned to your terminal's font and colour capabilities, and adds the instant-prompt block to `~/.zshrc` for faster shell startup.

> **Note:** Oh My Zsh is required for Powerlevel10k in this configuration.  `zshrc.base` activates p10k via the OMZ theme mechanism; p10k alone is not sufficient.

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
> configuration is layered via `git` includes.  Source the shell fragments
> from your startup files as shown in “Shell setup” below.
>
> **Order of operations:** the installer only writes to `~/.gitconfig`.  You
> should set up any shell startup files and the optional private overlay
> *before* you start a new login shell; this is usually a one‑time manual
> step per host.

### Shell setup

The public `zsh`, `bash`, and `shell` files are written to be sourced from your real shell startup files. There is no need to separately source the private files: helpers such as `source_if_exists` are defined to handle the private overlay as long as it exists.

Startup files are split into three layers:

- `shell/env.base`: shared environment for login and non-login shells. It sources `shell/env.private`.
- `shell/profile.base`: shared login-only profile setup. It sources `shell/env.base`.
- `zsh/*rc.base` and `bash/*rc.base`: shell-specific interactive setup. They source `shell/env.base` directly so non-login interactive shells get the same PATH and environment.

Add the following lines to these files:

```zsh
# ~/.zshrc

source "$HOME/.config/dotfiles-public/zsh/zshrc.base"
```

```zsh
# ~/.zprofile

source "$HOME/.config/dotfiles-public/zsh/zprofile.base"
```

```bash
# ~/.bashrc
source "$HOME/.config/dotfiles-public/bash/bashrc.base"
```

```bash
# ~/.bash_profile
source "$HOME/.config/dotfiles-public/bash/bash_profile.base"
```

```bash
# ~/.profile
source "$HOME/.config/dotfiles-public/shell/profile.base"
```

> **Do not symlink.** Many tools aggressively modify `~/.zshrc` and `~/.bash_profile` directly — `conda init`, `nvm`, Homebrew, various SDK installers. If those files are symlinks into your dotfiles repo, those appended lines end up committed (or dirtying your working tree). With sourcing, `~/.zshrc` is a plain file the tools can mutate freely; the repo stays clean.
>
> This is exactly why `install.sh` uses `[include]` for git rather than symlinking `~/.gitconfig` — `git config --global` would otherwise write into the tracked file.

### Full setup sequence for zsh with Powerlevel10k

Complete these steps in order on a new machine:

**Before** adding the source lines above:

1. Install a full [Nerd Font](https://www.nerdfonts.com) and configure your terminal to use it (see Prerequisites above).  iTerm2 and Termux users who are happy with MesloLGS NF can skip this step and let `p10k configure` install it automatically.

2. Install [Oh My Zsh](https://ohmyz.sh), passing `KEEP_ZSHRC=yes` so the installer does not overwrite your `~/.zshrc`:

   ```bash
   RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
   ```

3. Install [Powerlevel10k](https://github.com/romkatv/powerlevel10k) as an Oh My Zsh theme:

   ```bash
   git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
   ```

4. Install the two optional plugins into `$ZSH_CUSTOM/plugins/`:

   ```bash
   git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
   git clone https://github.com/zsh-users/zsh-syntax-highlighting "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
   ```

**Then** add the source lines shown above to your shell startup files.

**Finally**, run the Powerlevel10k wizard — it will write `~/.p10k.zsh` and add the instant-prompt block to `~/.zshrc`:

```zsh
p10k configure
```

---

## Optional Private Overlay

For anything that is *not* suitable for public consumption—API keys, host customizations, Wi‑Fi passwords, or just machine‑specific tweaks—put it in a parallel directory:

```text
~/.config/dotfiles-private/
```

If you create the directory manually, the following skeleton is a sensible starting point:

```text
~/.config/dotfiles-private/
├── git/
│   └── gitconfig.private          # extra `git` includes or overrides
├── zsh/
│   └── zshrc.private              # machine-specific shell additions
├── bash/
│   └── bashrc.private
└── shell/
    ├── env.private                # shared PATH and environment
    └── profile.private            # login-only shared settings
```

You don’t need to populate every subdirectory; only create the ones you
actually use.  Private profile files for zsh and bash are almost certainly not needed.  The public files already know how to source each `*.private` counterpart if it exists—no extra wiring is required.

Structure the private repo the same way as the public one: you may have a `git/gitconfig.private` to hold private git settings, a `zsh/zshrc.private` for shell customisations, etc.  The installer will automatically add an `include` for `gitconfig.private` if that file exists.  Your shell start‑up files in the public repo already source the corresponding private pieces if present.

> The private repository is managed by you (and may itself be git‑ignored or
> stored in a different host).  Nothing in the public repo depends on it, and
> you may delete the private directory entirely without breaking the public
> configuration.
