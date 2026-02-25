#!/usr/bin/env bash

# simple bootstrap installer for the public dotfiles
#
# idempotently adds include blocks to ~/.gitconfig and respects an optional
# private overlay.  Designed to be safe to run multiple times and from any
# working directory.

set -euo pipefail
IFS=$'\n\t'

# make sure we are operating from the repository root so that relative paths
# like "zsh/" would work if we ever extend the script.
cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1

PUB_DIR="${HOME}/.config/dotfiles-public"
PRIV_DIR="${HOME}/.config/dotfiles-private"
GITCONFIG="${HOME}/.gitconfig"

# create the gitconfig file if it does not already exist; this emulates
# the behaviour of `git config --global` which would normally create the file
# for us.
if [[ ! -e "${GITCONFIG}" ]]; then
  touch "${GITCONFIG}"
fi

# helper -------------------------------------------------------------------

ensure_include() {
  local path="$1"

  # guard against missing file (grep will fail otherwise)
  [[ -f "${GITCONFIG}" ]] || return 0

  # use fixed-string and -x to avoid accidental substring matches
  if ! grep -Fxq "path = ${path}" "${GITCONFIG}"; then
    printf "\n[include]\n\tpath = %s\n" "${path}" >> "${GITCONFIG}"
    echo "Added include: ${path}"
  fi
}

# Public includes (always present in the repository)
ensure_include "${PUB_DIR}/git/gitconfig.base"
ensure_include "${PUB_DIR}/git/gitconfig.aliases"

# Private overlay includes (only if present)
if [[ -d "${PRIV_DIR}" ]]; then
  # add whatever private files you standardize on
  [[ -f "${PRIV_DIR}/git/gitconfig.private" ]] && ensure_include "${PRIV_DIR}/git/gitconfig.private"
else
  echo "Private overlay not found at ${PRIV_DIR} (skipping)."
fi