# CHANGELOG

This repository follows the "Keep a Changelog" format and [Semantic Versioning](https://semver.org/).
Use this template to record notable changes in each release.

Format notes
------------
- Keep an "Unreleased" section at the top where you add notes while working on the next release.
- When releasing, move entries from `Unreleased` into a new version heading and add the release date.
- Use the sections below to categorize changes: `Added`, `Changed`, `Deprecated`, `Removed`, `Fixed`, `Security`.

Example
-------

## [Unreleased]

### Added
- Add `--no-cache` option to `build-image` script to speed up CI.

### Fixed
- Fix race condition in `entrypoint.sh` when starting db service.

## [1.2.0] - 2025-09-15

### Added
- Support for Proton-GE installation under `/opt` and registration in Steam `compatibilitytools.d`.

### Changed
- Normalize line endings in `*.sh` and `**/entrypoint.sh` via `.gitattributes`.
- Harden presence checks in multiple `entrypoint.sh` files (`${VAR}` -> `${VAR:-}` where unambiguous).

### Fixed
- Prevent `set -u` "unbound variable" runtime errors in entrypoint scripts.

Template
--------

## [Unreleased]

### Added
- 

### Changed
- 

### Deprecated
- 

### Removed
- 

### Fixed
- 

### Security
- 

## [X.Y.Z] - YYYY-MM-DD

### Added
- 

### Changed
- 

### Deprecated
- 

### Removed
- 

### Fixed
- 

### Security
- 

How to use
----------
1. While developing, add entries under `## [Unreleased]` in the appropriate section.
2. When preparing a release:
   - Change the `## [Unreleased]` entries into a new version heading like `## [1.3.0] - 2025-09-20`.
   - Create a new empty `## [Unreleased]` section at the top for future work.
3. Commit the changelog change and include the release tag.

Suggested Git workflow (example):

```bash
# Update changelog: move Unreleased -> new version and add date
git add CHANGELOG.md
git commit -m "chore(release): 1.3.0"
git tag -a v1.3.0 -m "Release 1.3.0"
git push origin main --tags
```

Tips
----
- Keep entries concise and targeted at users (not internal implementation details unless relevant).
- Use this changelog for release notes and to populate GitHub/GitLab release descriptions.
- Optionally automate parts of the release with scripts that read the `Unreleased` section and create a release draft.

Acknowledgements
----------------
Based on "Keep a Changelog" — https://keepachangelog.com/
