# robot-sync

Bidirectional rsync between a workstation and one or more remote robot targets. Drop it in any repo as a submodule and configure targets in a local `.env`.

## Setup

### 1. Add as a submodule (or clone standalone)

```bash
git submodule add https://github.com/NicoLuhmann/robot-sync robot-sync
```

Or just clone directly into your project:

```bash
git clone https://github.com/NicoLuhmann/robot-sync
```

### 2. Create `.env`

```bash
cp robot-sync/.env.example robot-sync/.env
```

Edit `robot-sync/.env` with your target details. The file is gitignored.

## .env format

```dotenv
# Default target — used when no target name is passed
DEFAULT_TARGET=robot

# One block per target: <NAME>_USER, <NAME>_IP, <NAME>_PATH
robot_USER=<ssh-user>
robot_IP=<ip-address>
robot_PATH=/path/to/repo

lan_USER=<ssh-user>
lan_IP=<lan-ip-address>
lan_PATH=/path/to/repo
```

Add as many targets as you need. Target names must match exactly between the CLI argument and the `<NAME>_*` prefix in `.env`.

## Usage

```bash
bash robot-sync/sync.sh               # push to DEFAULT_TARGET
bash robot-sync/sync.sh pull          # pull from DEFAULT_TARGET
bash robot-sync/sync.sh push lan      # push to the "lan" target
bash robot-sync/sync.sh pull robot    # pull from the "robot" target
```

Arguments can be given in any order.

## What is synced

The full parent repo root is synced in both directions. Files that exist on the destination but not on the source are deleted (`--delete`).

Always excluded:
- `.git/` — git history
- `.env` — local connection config
- `build/`, `install/`, `log/` — colcon build artifacts
- `*.log` — build/run logs
- `__pycache__/`, `*.pyc` — Python bytecode cache

If the parent repo contains `.rsyncignore`, its rsync exclude patterns are also
applied to both push and pull. `.gitignore` is not read by rsync. Use a leading
`/` to anchor a pattern at the parent repo root, or an unanchored directory name
such as `.venv/` to exclude it at any depth.

Excluded destination files are also protected from `--delete`. Adding an
exclusion leaves any previously synced copies in place; it does not remove them.
