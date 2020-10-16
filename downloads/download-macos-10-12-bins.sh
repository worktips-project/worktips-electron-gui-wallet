#!/bin/bash

set -e

if [ -z "$OS" ]; then
    echo "OS must be set"
    exit 1
fi

if [ -z "$RENAME" ]; then
    RENAME="latest"
fi

if [ "$OS" == "macOS" ]; then
    ASSET_URL="https://builds.lokinet.dev/jagerman/loki/macos1013/loki-macos-8.1.1-dev-0fc69272d.tar.xz"
else
    echo "OS must be Linux, Windows or macOS"
    exit 1
fi

echo "About to download the macos-10.12 binaries"

curl -sL --fail \
    -H "Accept: application/octet-stream" \
    -o "${RENAME}" \
    "$ASSET_URL"

echo "Loki binaries downloaded"