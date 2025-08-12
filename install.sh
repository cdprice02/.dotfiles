#!/usr/bin/env bash

set -e

CONFIG=""
DOTBOT_DIR="dotbot"

DOTBOT_BIN="bin/dotbot"
BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd "${BASEDIR}"

# Initialize submodules if not already done
git submodule update --init --recursive "${DOTBOT_DIR}"

# Detect OS and set appropriate config
case "$(uname -s)" in
    Linux*)
        echo "Detected Linux OS"
        CONFIG="install.conf.linux.yaml"
        ;;
    Darwin*)
        echo "Detected macOS (using Linux config)"
        CONFIG="install.conf.linux.yaml"
        ;;
    CYGWIN*|MINGW*|MSYS*)
        echo "Detected Windows OS"
        CONFIG="install.conf.windows.yaml"
        ;;
    *)
        echo "Unknown OS detected, defaulting to Linux config"
        CONFIG="install.conf.linux.yaml"
        ;;
esac

echo "Using config: ${CONFIG}"

# Run Dotbot with the appropriate configuration
"${BASEDIR}/${DOTBOT_DIR}/${DOTBOT_BIN}" -d "${BASEDIR}" -c "${CONFIG}" "${@}"