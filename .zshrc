alias k="kubectl"

alias darkmode="kitty +kitten themes --reload-in=all Rosé Pine && kitty @ set-background-image ~/.config/kitty/sekiro-bnw.png"
alias lightmode="kitty +kitten themes --reload-in=all Tokyo Night Day && kitty @ set-background-image none"

# bun completions
[ -s "/Users/marnixjanssen/.bun/_bun" ] && source "/Users/marnixjanssen/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# K8s autocomplete
autoload -Uz compinit
compinit
source <(kubectl completion zsh)

# pnpm
export PNPM_HOME="/Users/marnixjanssen/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

