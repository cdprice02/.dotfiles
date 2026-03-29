alias dotfiles='git -C ~/.dotfiles'
alias dotfiles-sync='git -C ~/.dotfiles pull'

# Source machine-local environment variables (not tracked)
if [[ -f "$HOME/.claude/.env.local" ]]; then
  source "$HOME/.claude/.env.local"
fi
