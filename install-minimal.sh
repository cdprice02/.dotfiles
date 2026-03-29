#!/usr/bin/env bash
# install-minimal.sh — bootstrap without Nix (work/corporate machines)
# Assumes: git is available, SSH key is set up for github.com
# Does NOT require: nix, sudo
set -euo pipefail

BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Initializing submodules..."
git -C "${BASEDIR}" submodule update --init --recursive

echo "==> Creating symlinks..."

symlink() {
  local src="$1" dst="$2"
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    echo "  Backing up $dst -> ${dst}.bak"
    mv "$dst" "${dst}.bak"
  fi
  ln -sfn "$src" "$dst"
  echo "  $dst -> $src"
}

symlink "${BASEDIR}/claude"      "${HOME}/.claude"
symlink "${BASEDIR}/copilot"     "${HOME}/.copilot"
mkdir -p "${HOME}/.ssh"
symlink "${BASEDIR}/ssh/config"  "${HOME}/.ssh/config"
symlink "${BASEDIR}/.bashrc"     "${HOME}/.bashrc"

echo ""
echo "==> Done."
echo ""
echo "Next steps:"
echo "  1. Copy ~/.claude/profiles/work/settings.local.json.example"
echo "     to ~/.claude/settings.local.json and fill in credentials."
echo "  2. Create ~/.claude/.env.local with machine-specific secrets."
echo ""
echo "To sync config later:"
echo "  git -C ~/.dotfiles pull --recurse-submodules"
echo "  git -C ~/.dotfiles submodule update --remote --merge"
