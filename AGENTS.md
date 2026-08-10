# AGENTS.md — grass-gis-addons-overview-generator

This repo is a **single Bash script** (`compile_addons_git.sh`) that discovers GRASS GIS addon repos on GitHub, compiles them, and generates an HTML manual page index. It is *not* the `OSGeo/grass-addons` repo — see [that repo's AGENTS.md](https://github.com/OSGeo/grass-addons/blob/grass8/AGENTS.md) for addon development conventions.

## Prerequisites

- **`gh` CLI**: installed and authenticated (`gh auth login`). The script searches common paths then PATH; errors if missing.
- **GRASS**: working installation matching addon major.minor version. Version parsed from `grass --config version`.
- **git**, **wget**, Python packages in `requirements.txt`.

## Running

```bash
bash compile_addons_git.sh
```

Flags: `-b` (binary path), `-m` (man page path), `-s` (source tree), `-w` (work dir), `-c` (cache dir), `--no-cache`.

## Caching (two levels)

1. **Repo cache** (`WORKDIR_REPOS`, default `/tmp/grass_addons_repos`): cloned repos persist; re-runs use `git pull --ff-only`. Delete dir for fresh clones.
2. **Compilation cache** (`~/.cache/grass_addons_compiler/addon_cache.json`): SHA256 checksum of source files. If unchanged and compiled output exists, addon is logged `CACHED` and skipped. `--no-cache` or `rm .../addon_cache.json` forces full rebuild.

## Architecture notes

- No build/test/lint tooling for the generator itself — it's a standalone script.
- Output: HTML manual pages at `$ADDONMANPATH/index.html`, compilation logs at `$ADDON_PATH/logs/index.html` (addon names link to their source GitHub repos via the Step 2 mapping CSV).
- `set -e` is **commented out** intentionally near the top of the script (script continues past non-fatal failures).
- GitHub API: queries topic `grass-gis-addons`, excludes `OSGeo/grass-addons`, limit 1000 repos. Authenticated rate: 5000/hr.
- Addon discovery: searches for Makefiles referencing `MODULE_TOPDIR` or defining `PGM`. Skips cookiecutter templates (contain `{{ }}`).
- `gh` binary lookup (before the GitHub API query): checks `/usr/bin/gh`, `/usr/local/bin/gh`, `/snap/bin/gh`, then PATH; verifies via `--version`.
- Workaround: creates `$TOPDIR/locale/scriptstrings` before compiling to avoid locale-related build failures.
- Generated addon manual pages get a navigation bar and hamburger menu/mobile TOC injected during HTML generation (Step 4).
- Repo-local `grass_logo.png` is copied into the HTML output using a preserved `ORIG_PWD` (replaces former SVG download+convert); missing file triggers only a warning.
- Docker: see `docker/run_docker.sh` (mounts repo, uses `osgeo/grass-gis:releasebranch_8_3-debian`).
- Weekly CI: GitHub Actions workflow at `.github/workflows/overview-generator.yml` runs in `osgeo/grass-gis` Docker container and deploys to GitHub Pages. Logs URL is driven by `LOGS_URL_PATH` env var.
- Compile-time deps: `grass-gis-helpers` (PyPI) is installed for addons that depend on it.

## Key files

| File | Purpose |
|---|---|
| `compile_addons_git.sh` | Entry point, all logic in a single script |
| `grass_logo.png` | Logo copied into generated HTML output (soft dependency; warning if missing) |
| `requirements.txt` | Python deps needed by various addons at compile time (annotated per addon in comments) |
| `docker/debian_docker_setup.sh` | Runs inside Debian container to install deps |
| `docker/run_docker.sh` | Mounts repo and starts container |
| `.github/workflows/overview-generator.yml` | Weekly CI workflow; builds in `osgeo/grass-gis` Docker container, deploys to GitHub Pages |
| `renovate.json` | Renovate config; auto-bumps GRASS Docker image tag via regex versioning |
