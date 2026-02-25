# CONTEXT

## Objective

We are restructuring shell and Git configuration into two layered repositories:

- `~/.config/dotfiles-public`
- `~/.config/dotfiles-private`

Each is an independent Git repository.

The goal is:

- Clean separation between public baseline and private overlay
- No secrets in public
- No machine-specific assumptions in public
- Public repo remains portable and framework-agnostic where possible
- Private repo handles tool-specific and machine-specific config

---

## Directory Constraints (CRITICAL)

Codex must operate ONLY inside:

- ~/dotfiles-public
- ~/dotfiles-private

Codex must NOT:

- Modify any other directories
- Modify ~/.profile, ~/.zshrc, ~/.bashrc, etc.

All changes must be contained within the two repositories.

---

## Architecture Model

We are implementing a layered configuration model:

public baseline + optional private overlay  = full working environment

### Public repo responsibilities

- Shell load structure
- Portable defaults
- Aesthetic choices allowed (Starship, Oh My Zsh, P10k)
- Guarded initialization of optional tools
- No secrets
- No hardcoded machine paths
- No package-manager-specific assumptions (e.g., no Homebrew shellenv)

### Private repo responsibilities

- Homebrew wiring
- PATH edits for specific tools
- SSH agent socket configuration
- Machine-specific paths
- Any sensitive or host-specific settings

---

## Shell Behavior Model

- `.profile` → shared login environment
- `.zprofile` → loads `.profile`
- `.bash_profile` → loads `.profile` and `.bashrc`
- `.zshrc` → interactive Zsh config
- `.bashrc` → interactive Bash config
- `.p10k.zsh` → contains P10K prefs

Current versions of these live inside dotfiles-public.
New public versions of these will live inside their respective child folders inside dotfiles-public.
Private overlays are sourced if present.

---

## Guard Pattern

All optional tool initialization must be guarded.

Preferred helpers:

has() { command -v "$1" >/dev/null 2>&1; }
source_if_exists() { [ -f "$1" ] && . "$1"; }

No unguarded `eval` or `source` of optional tools.

---

## Non-Goals

- No global system modifications
- No package installation
- No changes outside the two repos
- No rewriting unrelated config
