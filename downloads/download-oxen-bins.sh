#!/bin/bash

# THIS IS TEMPORARY. TO BE REMOVED ONCE OXEN STUFF IS IN STABLE ON LOKI/OXEN CORE

set -e

if [ -z "$OS" ]; then
    echo "OS must be set"
    exit 1
fi

if [ -z "$RENAME" ]; then
    RENAME="latest"
fi

if [ "$OS" == "Linux" ]; then
    ASSET_URL="https://oxen.rocks/darcys22/loki-core/oxen-rebrand/oxen-linux-x86_64-9.0.0-dev-d198af3de.tar.xz"
elif [ "$OS" == "Windows" ]; then
    ASSET_URL="https://oxen.rocks/darcys22/loki-core/oxen-rebrand/oxen-win-x64-9.0.0-dev-d198af3de.zip"
elif [ "$OS" == "macOS" ]; then
    ASSET_URL="https://oxen.rocks/darcys22/loki-core/oxen-rebrand/oxen-macos-x86_64-9.0.0-dev-d198af3de.tar.xz"
else
    echo "OS must be Linux, Windows or macOS"
    exit 1
fi

echo "About to download the binaries"

curl -sL --fail \
    -H "Accept: application/octet-stream" \
    -o "${RENAME}" \
    "$ASSET_URL"

echo "Oxen binaries downloaded"