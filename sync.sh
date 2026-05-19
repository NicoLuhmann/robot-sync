#!/bin/bash
# sync.sh — bidirectional rsync between this machine and a remote robot target
# See README.md for full documentation and .env.example for configuration.
#
# USAGE
#   bash robot-sync/sync.sh [push|pull] [target]
#
# EXCLUDED FROM SYNC
#   .git/  .env  build/  install/  log/  *.log  __pycache__/  *.pyc

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT="$( cd "${SCRIPT_DIR}/.." && pwd )"
ENV_FILE="${SCRIPT_DIR}/.env"

if [[ ! -f "$ENV_FILE" ]]; then
    echo "Error: no .env found at ${ENV_FILE}"
    echo ""
    echo "Copy the example and fill in your values:"
    echo "  cp ${SCRIPT_DIR}/.env.example ${ENV_FILE}"
    exit 1
fi

source "$ENV_FILE"

ACTION="push"
TARGET_NAME=""
for arg in "$@"; do
    case "$arg" in
        push|pull) ACTION="$arg" ;;
        *) TARGET_NAME="$arg" ;;
    esac
done

if [[ -z "$TARGET_NAME" ]]; then
    TARGET_NAME="$DEFAULT_TARGET"
fi

if [[ -z "$TARGET_NAME" ]]; then
    echo "Error: no target specified and DEFAULT_TARGET is not set in .env"
    echo ""
    echo "Either pass a target name:  bash robot-sync/sync.sh push <target>"
    echo "Or set DEFAULT_TARGET in ${ENV_FILE}"
    exit 1
fi

PREFIX="${TARGET_NAME^^}"
TARGET_USER=$(eval echo "\${${PREFIX}_USER}")
TARGET_IP=$(eval echo "\${${PREFIX}_IP}")
TARGET_PATH=$(eval echo "\${${PREFIX}_PATH}")

if [[ -z "$TARGET_USER" || -z "$TARGET_IP" || -z "$TARGET_PATH" ]]; then
    echo "Error: incomplete config for target '${TARGET_NAME}' in .env"
    echo ""
    echo "Required variables:"
    echo "  ${PREFIX}_USER   (currently: '${TARGET_USER}')"
    echo "  ${PREFIX}_IP     (currently: '${TARGET_IP}')"
    echo "  ${PREFIX}_PATH   (currently: '${TARGET_PATH}')"
    exit 1
fi

RSYNC_OPTS=(
    -av
    --delete
    --exclude='.git'
    --exclude='.env'
    --exclude='build/'
    --exclude='install/'
    --exclude='log/'
    --exclude='*.log'
    --exclude='__pycache__/'
    --exclude='*.pyc'
)

REMOTE="${TARGET_USER}@${TARGET_IP}:${TARGET_PATH}/"

if [[ "$ACTION" == "push" ]]; then
    echo "Pushing to ${REMOTE} ..."
    rsync "${RSYNC_OPTS[@]}" "${REPO_ROOT}/" "$REMOTE"
else
    echo "Pulling from ${REMOTE} ..."
    rsync "${RSYNC_OPTS[@]}" "$REMOTE" "${REPO_ROOT}/"
fi
