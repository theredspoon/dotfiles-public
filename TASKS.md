# TASKS

## EXECUTION INSTRUCTIONS FOR CODEX

1. Read CONTEXT.md first.
2. Treat CONTEXT.md as binding constraints.
3. Operate ONLY within:
   - dotfiles-public
   - dotfiles-private
4. Refuse any task that requires touching files outside those directories.
5. After completing tasks, provide a concise summary of changes.

## Scope Restriction

All work must be limited to:

- ~/dotfiles-public
- ~/dotfiles-private

Do not access or modify any other directories.

---

## PHASE 1

## LAST PHASE — Validation

Confirm:

- Public repo contains no machine-specific absolute paths.
- Public repo contains no secrets.
- Public repo is portable across macOS/Linux.
- Private repo contains all sensitive and OS-specific wiring.
- No changes were made outside the two allowed directories.

---

## Output Requirements

Codex should:

- Modify only files inside the two repositories.
- Provide a concise summary of changes made.
