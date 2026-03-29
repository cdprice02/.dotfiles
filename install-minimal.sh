#!/usr/bin/env bash
# install-minimal.sh — bootstrap without dotbot (work/corporate machines)
# Assumes: git is available, SSH key is set up for github.com
# Does NOT require: nix, dotbot, sudo
set -euo pipefail

BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Initializing submodules..."
git --git-dir="${HOME}/.dotfiles" --work-tree="${HOME}" \
  submodule update --init --recursive

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
echo "  git --git-dir=~/.dotfiles --work-tree=~ pull"
echo "  git --git-dir=~/.dotfiles --work-tree=~ submodule update --remote --merge"
