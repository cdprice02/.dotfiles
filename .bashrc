alias dotfiles='git -C ~/.dotfiles'
alias dotfiles-sync='git -C ~/.dotfiles pull --recurse-submodules && git -C ~/.dotfiles submodule update --remote --merge'

# Source machine-local environment variables (not tracked)
if [[ -f "$HOME/.claude/.env.local" ]]; then
  source "$HOME/.claude/.env.local"
fi
