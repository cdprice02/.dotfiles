#!/usr/bin/env bash
# install-minimal.sh — bootstrap without Nix (work/corporate machines)
# Sets up shell and SSH config only.
# Assumes: git is available, SSH key is set up for github.com
# Does NOT require: nix, sudo
set -euo pipefail

BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

symlink "${BASEDIR}/.bashrc"    "${HOME}/.bashrc"
mkdir -p "${HOME}/.ssh"
symlink "${BASEDIR}/ssh/config" "${HOME}/.ssh/config"

echo ""
echo "==> Done."
echo ""
echo "To set up Claude Code config:"
echo "  git clone git@github.com:cdprice02/claude-config ~/.claude"
echo "  cp ~/.claude/profiles/work/settings.local.json.example ~/.claude/settings.local.json"
echo "  cp ~/.claude/profiles/work/CLAUDE.work.md ~/.claude/CLAUDE.local.md"
echo "  # Fill in ~/.claude/settings.local.json and create ~/.claude/.env.local"
echo ""
echo "To set up Copilot config:"
echo "  git clone git@github.com:cdprice02/copilot-config ~/.copilot"
echo ""
echo "To sync dotfiles later:"
echo "  git -C ~/.dotfiles pull"
