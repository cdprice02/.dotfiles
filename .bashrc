alias dotfiles='/usr/bin/git --git-dir=/Users/cdprice/.dotfiles/ --work-tree=/Users/cdprice'

# Source machine-local environment variables (not tracked)
if [[ -f "$HOME/.claude/.env.local" ]]; then
  source "$HOME/.claude/.env.local"
fi
