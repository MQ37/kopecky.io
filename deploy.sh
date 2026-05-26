#!/bin/bash
set -euo pipefail

# Deploy to a server via rsync.
# Usage: ./deploy.sh [user@]host[:path]
# Defaults to the DEPLOY_TARGET env var if set.

TARGET="${1:-${DEPLOY_TARGET:-}}"

if [ -z "$TARGET" ]; then
    echo "Usage: ./deploy.sh [user@]host[:path]"
    echo "  or set DEPLOY_TARGET env var"
    exit 1
fi

echo "==> Building site"
./build.sh

echo "==> Deploying to $TARGET"
rsync -avz --delete public/ "$TARGET"
echo "==> Done"
