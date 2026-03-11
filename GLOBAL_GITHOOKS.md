# Global Git hooks example

Use this pattern if you want one global Git hook setup that still respects tracked
repo-local hooks in `.githooks/`.

## Why this pattern

- One-time Git configuration on your machine.
- Local repo hooks stay versioned with each project.
- Safe defaults still run in repos that don't define local hooks.

## Global setup

```bash
git config --global core.hooksPath ~/.githooks
mkdir -p ~/.githooks/defaults
chmod +x ~/.githooks/pre-commit ~/.githooks/pre-push
chmod +x ~/.githooks/defaults/pre-commit ~/.githooks/defaults/pre-push
```

## Dispatcher hooks

Create `~/.githooks/pre-commit`:

```sh
#!/bin/sh
set -eu

repo_root=$(git rev-parse --show-toplevel 2>/dev/null || true)

if [ -n "${repo_root:-}" ] && [ -x "$repo_root/.githooks/pre-commit" ]; then
  exec "$repo_root/.githooks/pre-commit" "$@"
fi

if [ -x "$HOME/.githooks/defaults/pre-commit" ]; then
  exec "$HOME/.githooks/defaults/pre-commit" "$@"
fi

exit 0
```

Create `~/.githooks/pre-push`:

```sh
#!/bin/sh
set -eu

repo_root=$(git rev-parse --show-toplevel 2>/dev/null || true)

if [ -n "${repo_root:-}" ] && [ -x "$repo_root/.githooks/pre-push" ]; then
  exec "$repo_root/.githooks/pre-push" "$@"
fi

if [ -x "$HOME/.githooks/defaults/pre-push" ]; then
  exec "$HOME/.githooks/defaults/pre-push" "$@"
fi

exit 0
```

## Safe fallback defaults

Create `~/.githooks/defaults/pre-commit`:

```sh
#!/bin/sh
set -eu

staged_files=$(git diff --cached --name-only --diff-filter=ACMR)

[ -n "$staged_files" ] || exit 0

IFS='
'
for path in $staged_files; do
  [ -f "$path" ] || continue

  if grep -nE '^(<<<<<<<|=======|>>>>>>>)' "$path" >/dev/null 2>&1; then
    echo "pre-commit: merge conflict markers found in $path" >&2
    exit 1
  fi

  case "$path" in
    *.md|*.txt|*.sh|*.yml|*.yaml|*.json)
      if grep -n '[[:blank:]]$' "$path" >/dev/null 2>&1; then
        echo "pre-commit: trailing whitespace found in $path" >&2
        exit 1
      fi
      ;;
  esac
done
unset IFS

exit 0
```

Create `~/.githooks/defaults/pre-push`:

```sh
#!/bin/sh
set -eu

exit 0
```

## How it behaves

- If a repo has an executable `.githooks/pre-commit`, Git runs that.
- Otherwise Git runs your global fallback `~/.githooks/defaults/pre-commit`.
- The same dispatch applies to `pre-push`.

This scaffold already includes repo-local `.githooks/` scripts. The dispatcher lets
those tracked scripts stay authoritative without requiring `git config core.hooksPath
.githooks` in every clone.
