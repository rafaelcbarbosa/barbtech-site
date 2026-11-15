#!/usr/bin/env sh
# Pull the latest site revision on the home server.
# Install with a crontab entry; see README.md.
set -eu
cd "$(dirname "$0")/.."
git pull --ff-only
