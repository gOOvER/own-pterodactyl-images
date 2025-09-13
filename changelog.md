# CHANGELOG

This repository follows the "Keep a Changelog" format and [Semantic Versioning](https://semver.org/).
Use this changelog to record notable changes in each release.

## [Unreleased]

### Summary

- Line ending normalization: Many `entrypoint.sh` scripts were normalized from CRLF to LF (added/updated `.gitattributes`).
- Hardened presence checks: Several `entrypoint.sh` files had their presence tests made more robust (e.g. `${VAR}` → `${VAR:-}` in unambiguous test cases) to avoid `set -u` "unbound variable" runtime errors.

### Why these changes

- Consistent line endings prevent platform-specific syntax errors and unnecessary diffs.
- Safer variable usage in test expressions reduces runtime crashes in containers using `set -u` or strict Bash modes.

### Key details

- Files changed: 74 files modified in commit `92bc516`.
- Two helper scripts were added under `./.tools/`:
  - `.tools/fix_entrypoints.py` (initial heuristic pass)
  - `.tools/safe_fix_entrypoints.py` (safer, tightly scoped pass)
- `.gitattributes` was updated to force LF for `*.sh` and `**/entrypoint.sh`.

### Areas affected (selected)

- `steam/entrypoint.sh`, `steamcmd/entrypoint.sh`, `wine/entrypoint.sh`
- several `games/*/entrypoint.sh` (e.g. `aloft`, `valheim`, `rust`, `armareforger`, `bannerlord`, `wurm`)
- various `dev/*` and `alpine/*` entrypoints

### Testing & revert notes

- Lint / syntax check:

```bash
# Example: syntax-check an entrypoint
bash -n ./steam/entrypoint.sh
```

- Local smoke test: build the Docker image and run it briefly (for the specific image subproject).

- Revert (if needed): a single file can be reset to the previous commit:

```bash
git checkout 92bc516^ -- path/to/affected/entrypoint.sh
```

### Recommended next steps

1. (Optional) Code review of modified entrypoints; pay special attention to complex inline command substitutions (`$(...)`), `printf` constructs, and combined `steamcmd`/`DepotDownloader` invocations.
2. Optionally convert additional fragile shell patterns to argument-array based constructs (avoids word-splitting).
3. Run smoke tests for the primary images (`steam`, `wine`, `depotdl`) in a test environment.

### Contact / follow-up

If you like, I can split these changes into smaller, thematic commits, prepare a short PR template, or further harden security-sensitive patterns (such as `eval` / `bash -lc` on `STARTUP`).

## [1.2.0] - 2025-09-15

### Added
- Support for Proton-GE installation under `/opt` and registration in Steam `compatibilitytools.d`.

### Changed
- Normalize line endings in `*.sh` and `**/entrypoint.sh` via `.gitattributes`.
- Harden presence checks in multiple `entrypoint.sh` files (`${VAR}` -> `${VAR:-}` where unambiguous).

### Fixed
- Prevent `set -u` "unbound variable" runtime errors in entrypoint scripts.
# Changelog

Date: 2025-09-13
Commit: `92bc516`

## Summary

- Line ending normalization: Many `entrypoint.sh` scripts were normalized from CRLF to LF (added/updated `.gitattributes`).
- Hardened presence checks: Several `entrypoint.sh` files had their presence tests made more robust (e.g. `${VAR}` → `${VAR:-}` in unambiguous test cases) to avoid `set -u` "unbound variable" runtime errors.

## Why these changes

- Consistent line endings prevent platform-specific syntax errors and unnecessary diffs.
- Safer variable usage in test expressions reduces runtime crashes in containers using `set -u` or strict Bash modes.

## Key details

- Files changed: 74 files modified in commit `92bc516`.
- Two helper scripts were added under `./.tools/`:
  - `.tools/fix_entrypoints.py` (initial heuristic pass)
  - `.tools/safe_fix_entrypoints.py` (safer, tightly scoped pass)
- `.gitattributes` was updated to force LF for `*.sh` and `**/entrypoint.sh`.

## Areas affected (selected)

- `steam/entrypoint.sh`, `steamcmd/entrypoint.sh`, `wine/entrypoint.sh`
- several `games/*/entrypoint.sh` (e.g. `aloft`, `valheim`, `rust`, `armareforger`, `bannerlord`, `wurm`)
- various `dev/*` and `alpine/*` entrypoints

## Testing & revert notes

- Lint / syntax check:

```bash
# Example: syntax-check an entrypoint
bash -n ./steam/entrypoint.sh
```

- Local smoke test: build the Docker image and run it briefly (for the specific image subproject).

- Revert (if needed): a single file can be reset to the previous commit:

```bash
git checkout 92bc516^ -- path/to/affected/entrypoint.sh
```

## Recommended next steps

1. (Optional) Code review of modified entrypoints; pay special attention to complex inline command substitutions (`$(...)`), `printf` constructs, and combined `steamcmd`/`DepotDownloader` invocations.
2. Optionally convert additional fragile shell patterns to argument-array based constructs (avoids word-splitting).
3. Run smoke tests for the primary images (`steam`, `wine`, `depotdl`) in a test environment.

## Contact / follow-up

If you like, I can split these changes into smaller, thematic commits, prepare a short PR template, or further harden security-sensitive patterns (such as `eval` / `bash -lc` on `STARTUP`).
